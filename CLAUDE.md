# CLAUDE.md

Build commands, style, and PR conventions live in [AGENTS.md](AGENTS.md). This
file records the things that have actually gone wrong here, because none of them
are visible from reading the Dockerfile.

## What this repo is

Docker images of RStudio Server + R, published to Docker Hub (`zatzmanm/rstudio`)
and GHCR (`ghcr.io/mjz1/rstudio-img`) for R 4.3–4.6.

**The images are consumed on an HPC cluster via Singularity**, converted to
`.sif` and run by an Open OnDemand app (see `mjz1/rstudio-ood`, the
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

The rootless **smoke suite** lives in `ci/*.sh` and runs in PR validation
(job `smoke`, one R version off the warm gha cache) AND in every publish
matrix job between build and push: the image invariants (no baked cookie key,
readable `database.conf`, `logger-type=stderr`, `xelatex` on `PATH`, the
assistants enabled), a real rserver launch with the downstream app's flag set
serving its sign-in page, headless Chrome rendering, and Quarto rendering an
actual PDF. Add a check whenever you fix a runtime bug; each existing one
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

- `4.3`–`4.6` and `latest` are **rolling**: the scheduled rebuilds move them --
  weekly when Posit ships a new stable RStudio Server, monthly unconditionally
  (R patch releases, Quarto and the apt layer drift independently of RStudio,
  so the gate cannot replace the monthly rebuild). Anything downstream that
  needs reproducibility must pin by digest.
- The weekly gate reads the `io.github.mjz1.rstudio-img.rstudio-server-version`
  label of **every rolling tag on both registries** and skips only when all of
  them carry the current release. The gate's unit must equal the push unit:
  pushes happen per-matrix-job per-registry, so a partial publish (one R
  version failed smoke, one registry push exhausted retries) leaves a mix --
  a gate that read only ghcr `latest` would be satisfied by that mix and skip
  forever while the other tags stayed stale.
- The weekly gate **fails open**: a missing image, missing label, or registry
  error reads as not-current and triggers a build. The worst failure mode is
  an unnecessary rebuild, never a silently missed release.
- **Nothing is pushed that has not run.** The publish workflow executes the
  smoke suite (`ci/*.sh`) between build and push in every matrix job -- the
  same scripts PR validation runs, so the two cannot drift apart. Edit the
  scripts, not the workflows, to change what is checked.
- `ci/smoke_launch.sh` starts rserver with the downstream OnDemand app's
  exact flag set (mirrors `template/script.sh.erb` in mjz1/rstudio-ood).
  When that app changes its rserver invocation, this script needs the same
  change -- and if Posit removes a flag and it has to be dropped here, the
  app needs the matching edit before it can run that RStudio version.
- When a scheduled run detects a new RStudio release it opens a GitHub issue
  with Posit's release notes for the new version(s). That issue is the
  human notification that the rolling tags moved and why; review it for
  option deprecations and auth changes, then close it.
- Publishing happens on a GitHub release, a `workflow_dispatch`, or the
  scheduled rebuilds (monthly unconditional, weekly gated). Merging to `main`
  runs PR validation, which builds but does not push.
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

One image serves CPU and GPU; there is no `-cuda` variant and the CI matrix does
not fork. GPU works via the host driver (`--nv` under Singularity, `--gpus` under
Docker) plus a framework that bundles most of its own CUDA (`torch` downloads a
CUDA-enabled backend with its own cuBLAS/cuDNN).

**But the image DOES ship `libcudart`**, and this was a hard-won correction to an
earlier "no CUDA toolkit at all" assumption. `--nv` gives only the *driver*
(`libcuda.so`), not the CUDA *runtime*. R torch's `liblantern.so` links the plain
soname `libcudart.so.12` and resolves it from `ldconfig`; PyTorch bundles a
hash-mangled `libcudart-<hash>.so.12` that lantern cannot see by name. So without
a system `libcudart`, `cuda_is_available()` is FALSE on a GPU node even though
`nvidia-smi` works — verified the hard way. Both majors (`cuda-cudart-12-9`,
`cuda-cudart-13-0`, ~5 MB) are installed unconditionally; the CI smoke test
asserts both sonames. This mirrors how rocker's retired CUDA images worked
(system runtime via `ldconfig`; see rocker-org/ml). Do not remove it thinking
"torch is self-contained" — it is not, for R.

`WITH_CUDA=1` (default off) adds the *fuller* runtime (cuBLAS/cuFFT/… via
`CUDA_RUNTIME_PACKAGES`) on top, for packages that dlopen system versions beyond
cudart (Python TensorFlow, nvcc code). The full GPU stack (TensorFlow, GPU-BLAS,
RAPIDS) is scoped in issue #14. If you enable it, the driver caps the usable CUDA
version; pin accordingly.

The consumer supplies the driver and requests the device. For the OnDemand app
(`mjz1/rstudio-ood`), that is `--gres=gpu:N` plus `--nv`, with `--nv` gated
on a runtime `/dev/nvidia*` probe — see that repo's CLAUDE.md.

## Headless Chrome

The image ships **Google Chrome** so R packages that rasterise HTML can work:
`webshot2`, `gt::gtsave("*.png")`, `pagedown::chrome_print()` — all drive Chrome
through `chromote`. Issue #1 was `gt` failing to save a PNG because no browser
was present. Two things here are not obvious from the Dockerfile:

- **Do not use Ubuntu's apt `chromium`/`chromium-browser`.** On noble it is a
  transitional *snap*; snaps do not run inside a container, so it "installs" and
  then fails at runtime. Google Chrome's own `.deb` is a real binary and pulls
  its runtime deps (`libnss3`, fonts, …) via apt.
- **Rootless breaks Chrome's sandbox, so it must run `--no-sandbox`.** The
  sandbox needs a setuid helper or nested user namespaces; under Singularity
  neither exists, so Chrome cannot spawn its zygote and dies. `chromote` only
  adds `--no-sandbox` automatically when `uid == 0`, which never holds here. So
  `CHROMOTE_CHROME` is set to `/usr/local/bin/chrome-headless-shim`, a wrapper
  that always execs Chrome with `--no-sandbox --disable-gpu
  --disable-dev-shm-usage` (the last because `/dev/shm` is tiny in a container
  and Chrome crashes writing there). Every `chromote`-based package reads
  `CHROMOTE_CHROME`, so pointing it at the wrapper fixes all of them at once. If
  you ever bypass the wrapper (calling `google-chrome` directly), you own the
  flags.

The smoke test renders a data-URI screenshot as uid 1000 — a real rootless
render, not just "the binary exists," because a present-but-unusable Chrome is
exactly the silent failure this repo keeps shipping.
