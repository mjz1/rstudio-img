# CLAUDE.md

Build commands, style, and PR conventions live in [AGENTS.md](AGENTS.md). This
file records the things that have actually gone wrong here, because none of them
are visible from reading the Dockerfile.

## What this repo is

Docker images of RStudio Server + R, published to Docker Hub (`zatzmanm/rstudio`)
and GHCR (`ghcr.io/mjz1/rstudio-img`) for R 4.3–4.6.

**The images are consumed on an HPC cluster via Singularity**, converted to
`.sif` and run by an Open OnDemand app (see `mjz1/openondemandapps`, the
`rstudio_dev` app). That downstream consumer is the reason most of the rules
below exist. Rolling tags `4.3`–`4.6` and `latest` are what the cluster syncs;
treat them as production.

## The failure mode that keeps recurring

**Errors here have nowhere to surface.** Every serious bug this repo has shipped
was a *silent* failure that CI reported as green:

- `logger-type=syslog` (inherited from rocker) means `rserver` startup errors are
  discarded — there is no syslog socket in a container. A fatal error looked
  exactly like "the port never opened."
- A `RUN` ending in `cmd && break || echo ... && sleep 5` exits 0 even when
  `cmd` failed every time. It shipped an image with no TeX in it.
- `xelatex --version | head -1` exits 0 when `xelatex` does not exist, unless
  `pipefail` is set. Prefer `command -v foo && foo --version`.
- `find /` as a non-root user silently skips `/root` (mode 0700). "Not found" is
  not the same as "not there."

When adding a build step, ask: *if this failed, what would I see?* If the answer
is "nothing," add an explicit check that fails the `RUN`.

## Rootless is the primary runtime

The image is built as root but almost never *run* as root. Singularity runs it as
you; the SIF filesystem is read-only regardless of what the permissions say.

- Anything installed into `$HOME` during the build lands in `/root` (mode 0700)
  and is invisible to every real user. TinyTeX hit this. Install to `/opt` and
  `chmod -R a+rX`.
- Anything that needs to *write* at runtime cannot live inside the image.
  TinyTeX's `TEXMFVAR`/`TEXMFCONFIG` are redirected to `~/.texlive/…` for this
  reason; otherwise `luaotfload` cannot build its font cache and PDF rendering
  dies.
- Config files the deb ships `0600 root:root` are unreadable. `database.conf` is
  written explicitly with no secrets in it, mode `0644`, precisely so it can be
  world-readable. Do not "fix" that by tightening it.
- The `secure-cookie-key` must not exist in the image. The deb's postinst
  regenerates it on every install; baked into a published image it is a shared
  secret that signs auth cookies for everyone who pulls that tag. Rocker deletes
  it; so do we. See the v1.1.1 security note in CHANGELOG.md.

## Reinstalling the RStudio deb

The Dockerfile installs a newer `rstudio-server` deb over the rocker base. That
re-runs the deb's postinst, which **undoes rocker's post-install fixups**. If you
touch that step, re-read rocker's
[`install_rstudio.sh`](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh)
and check nothing else was silently reverted.

## Verifying a change without a full rebuild

A full matrix build is ~15 min/image. To test a behavioural change, build a
two-line derived image and A/B it against the published one:

```dockerfile
FROM ghcr.io/mjz1/rstudio-img:4.5
RUN <the thing you changed>
```

```bash
podman build -f Dockerfile.test -t test:4.5 .
podman run --rm --user 1000:1000 test:4.5 <the check>          # rootless, the real case
podman run --rm --user 1000:1000 ghcr.io/mjz1/rstudio-img:4.5 <the check>   # control
```

**Always run the control.** Twice during this repo's history a test "passed" for
both the fixed and broken image because it was failing for an unrelated reason
(a missing `libR.so`; a root-owned `--tmpfs`). A test that cannot fail proves
nothing — verify a new check *fails* on an image that lacks the fix.

PR validation runs a rootless **smoke test** (`pr-validation.yaml`, job `smoke`)
that asserts the invariants above: no baked cookie key, a readable
`database.conf`, `logger-type=stderr`, `xelatex` on `PATH`, the assistants
enabled, `rserver --verify-installation` exiting 0 as uid 1000, and Quarto
rendering an actual PDF. It builds one R version with `load: true` off the warm
gha cache. Add a check here whenever you fix a runtime bug; each of those lines
corresponds to a regression that shipped.

## Config options are not what the docs say

`rsession` treats an unrecognised option in `rsession.conf` as **fatal**. Two
consequences:

- Never add an option without checking the binary supports it:
  `grep -aq 'the-option' /usr/lib/rstudio-server/bin/rsession`. The Dockerfile
  guards Posit Assistant this way, so a build pinned to an older
  `RSTUDIO_VERSION` degrades rather than shipping unbootable sessions.
- Read the [rsession.conf
  reference](https://docs.posit.co/ide/server-pro/admin/reference/rsession_conf.html),
  not the user guide. `posit-assistant-enabled` defaults to `1` and
  `allow-posit-assistant` defaults to `0` — the one that sounds like the switch
  is not the one that gates the feature.

## Tags and releases

- `4.3`–`4.6` and `latest` are **rolling**: the monthly scheduled rebuild moves
  them. Anything downstream that needs reproducibility must pin by digest.
- Publishing only happens on a GitHub release (or `workflow_dispatch`). Merging
  to `main` runs PR validation, which builds but does not push.
- Tag rules in `build_push.yaml` are guarded against `refs/heads/dev` so a
  dispatch from `dev` cannot move the rolling tags. Keep new rules guarded.
- **Every tag rule runs once per matrix entry.** Any rule not keyed on
  `matrix.r_version` gets pushed by all four jobs, and the last to finish wins —
  a race whose winner can differ per registry. `type=ref,event=tag` and
  `metadata-action`'s default `flavor: latest=auto` both did this, and shipped a
  `latest` pointing at R 4.4 in v1.2.0. `flavor: latest=false` is now set, and
  the bare release tag is keyed on `LATEST_R_VERSION`. After any release, check
  that `latest` and `vX.Y.Z` resolve to the same digest as `vX.Y.Z-r<LATEST>`,
  on *both* registries.
- A published version is never overwritten. v1.1.0 was **withdrawn** rather than
  rebuilt in place: overwriting a tag remediates nothing (the bad image is
  already in caches) while destroying the ability to tell fixed from broken.

## Size

The image is large and every megabyte is paid on each `docker pull`, each
`singularity pull`, and each SIF conversion. `nvidia-cuda-dev` was 4.51 GB of a
9.57 GB apt footprint and nothing linked against it. Before adding a heavy
dependency, check whether anything actually needs it:

```bash
find "$R_LIBS" -name '*.so' | xargs objdump -p | grep NEEDED | grep -i <lib>
```

## GPU / CUDA

The image ships **no CUDA toolkit**, on purpose. GPU works via the host driver
(`--nv` under Singularity, `--gpus` under Docker) plus a framework that bundles
its own CUDA — `torch`/`tensorflow` download a CUDA-enabled backend at runtime.
So one image serves CPU and GPU; there is no `-cuda` variant and the CI matrix
does not fork.

`WITH_CUDA` (build arg, default `0`) is a hook for the uncommon package that
dlopens the *system* CUDA runtime: it adds NVIDIA's apt repo and installs
`CUDA_RUNTIME_PACKAGES` (default just `cuda-cudart-12-6`). **CI does not set it**,
so published images stay lean — flipping it on, or adding a `-cuda` tag, is the
deferred Tier-2 decision in issue #14. If you do enable it, the driver on the
target host caps the usable CUDA version; pin `CUDA_RUNTIME_PACKAGES`
accordingly.

The consumer supplies the driver and requests the device. For the OnDemand app
(`mjz1/openondemandapps`), that is `--gres=gpu:N` plus `--nv`, with `--nv` gated
on a runtime `/dev/nvidia*` probe — see that repo's CLAUDE.md.
