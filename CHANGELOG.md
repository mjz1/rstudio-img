# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Posit Assistant is enabled in `/etc/rstudio/rsession.conf`. Note the two options have opposite defaults: `posit-assistant-enabled` defaults to `1` ("integration may be enabled") while `allow-posit-assistant` defaults to `0` ("use of the feature is allowed") — the latter is what actually gates it, so both are set. Requires RStudio Server >= 2026.04; the build probes `rsession` for the option and skips it on older builds, because an unrecognised option in `rsession.conf` is fatal and would leave sessions unable to start.
- Nothing leaves the machine without user action: on first use RStudio fetches the assistant agent (~3.7 MB) from `cdn.posit.co` into `~/.posit/assistant`, and the user must sign in to Posit AI. Compute nodes therefore need outbound HTTPS to `cdn.posit.co`.

## [1.1.1] - 2026-07-09

### Security
- The RStudio Server deb's postinst generates `/var/lib/rstudio-server/secure-cookie-key`, and reinstalling the deb over the rocker base (added in 1.1.0) meant that key was baked into every published image. Since it signs RStudio auth cookies, every puller of a given tag shared the same key and could forge session cookies against any server running that image. Rocker deletes this file for exactly this reason ([rocker-versioned2#137](https://github.com/rocker-org/rocker-versioned2/issues/137)); we now do too, so it is regenerated on first run. **Affects all images published since v1.1.0.**

### Fixed
- `rserver` failed to start under any rootless runtime (Singularity/Apptainer, `podman run --user`, OpenShift). The deb ships `/etc/rstudio/database.conf` as `0600 root:root` because it may hold a Postgres password; RStudio Server 2026.06+ treats an unreadable `database.conf` as fatal, where 2025.09 ignored it. The file is now written explicitly with no secrets in it and mode `0644`.
- `logger-type` changed from `syslog` to `stderr`. There is no syslog socket in a container, so `rserver` startup failures were discarded entirely — the only symptom was the server never opening its port. (Rocker's `install_rstudio.sh` comments `# Log to stderr` immediately above setting `syslog`.)

## [1.1.0] - 2026-07-09 — WITHDRAWN

> **Withdrawn. Do not use.** Every image published under v1.1.0 carries a baked
> `secure-cookie-key` (see the v1.1.1 Security note above). The `v1.1.0` and
> `v1.1.0-r4.x` tags are being removed from Docker Hub and GHCR. The version
> number is burned and will not be reused; use v1.1.1 or later.
>
> Images built from this release are still addressable by digest in both
> registries — deleting a tag does not unpublish the manifest. If you pinned by
> digest, re-pin. If you pulled an affected image, re-pull and discard the old
> one; running `rserver` from it without a writable bind over
> `/var/lib/rstudio-server` will use the shared key.

### Added
- R 4.6 build, now the default and the `latest` tag (matrix: 4.3, 4.4, 4.5, 4.6).
- RStudio Server is upgraded to the latest stable Posit release at build time. The rocker base images pin the RStudio version that was current when each R version was last built (e.g. the R 4.3 base shipped RStudio 2023.12.1 from Dec 2023). New `RSTUDIO_VERSION` build arg accepts a channel (`stable`, `preview`, `daily`) or an exact version (e.g. `2026.06.0+242`).
- CI resolves the current stable RStudio Server version and passes it as a build arg, so new Posit releases bust the Docker layer cache and builds are reproducible.
- Monthly scheduled build (1st of each month) so rolling tags pick up new RStudio Server, Quarto, and R patch releases without a manual release.
- Dependabot configuration for GitHub Actions version updates.
- Makefile: `build-4.6` target.

### Changed
- Default R version bumped from 4.5 to 4.6 (Dockerfile, Makefile, docker-compose).

### Fixed
- `org.opencontainers.image.source` label pointed at the wrong GitHub owner (`zatzmanm` → `mjz1`).

## [1.0.1] - 2026-01-09

### Fixed
- Resolve R 4.3 build failure by removing `librdf0-dev`, which pulled in `libraptor2-dev` and conflicted with `libcurl4-openssl-dev`.

### Changed
- CI: PR validation workflow now builds all R matrix versions (4.3, 4.4, 4.5) to catch version-specific build issues early.
- CI: Build workflow now publishes dev images on push to `dev` branch, tagged with `-dev` suffix (e.g., `4.5-dev`, `dev`).

### Added
- Makefile: `build-all` target to build images for R 4.3, 4.4, and 4.5 in one command.
- Makefile: `pr-validate` target to run linters and `build-all` locally, mirroring CI PR validation.
- Documentation updates in README and AGENTS to reflect local validation steps and removal of automated runtime tests.

## [1.0.0] - 2026-01-09

### Added
- Matrix builds for R versions 4.3, 4.4, and 4.5
- Semantic versioning with release tags (e.g., `v1.0.0-r4.5`)
- Docker Compose setup for local development
- Linting workflow with hadolint and shellcheck
- PR validation workflow with build verification
- GitHub Container Registry (GHCR) publishing alongside Docker Hub
- `.dockerignore` and `.gitignore` files
- `.env.example` for easy configuration
- Healthcheck for Docker Compose service
- Image metadata labels
- CHANGELOG.md
- Makefile with convenient commands for development
- AGENTS.md with guidelines for AI coding assistants
- Comprehensive README documentation

### Changed
- **BREAKING:** Removed multi-architecture builds - images are now AMD64 only for consistency
- Simplified Dockerfile by removing all architecture conditionals (TARGETARCH logic)
- All packages (CUDA, TinyTeX) now installed unconditionally on AMD64
- ARM64 users can still run images via Docker emulation (automatic on Apple Silicon)
- CI/CD builds ~2-3x faster with single architecture (~15-20 min → ~5-7 min)
- Docker Compose now explicitly specifies `platform: linux/amd64`
- Makefile build commands include `--platform linux/amd64` flag
- Parameterized Dockerfile with `ARG R_VERSION`
- Optimized Dockerfile layers (reduced from ~95 to ~10)
- Updated GitHub Actions to use version tags instead of SHA pins
- Improved shell scripts with proper error handling
- Consolidated RUN commands for better caching
- Removed runtime test suite to reduce CI complexity and disk usage
- Images now published to both Docker Hub and GitHub Container Registry

### Fixed
- Missing `ARCH` variable in `install_quarto_latest.sh` with proper error handling
- CI disk space issues by removing runtime container testing
- Duplicate `apt-get update` commands merged
- Applied Dockerfile best practices (--no-install-recommends, pipefail)
- Hadolint DL3008 warnings properly suppressed where appropriate

## Previous Releases

### Added
- R 4.5.1 support
- Copilot integration
- Quarto with tinytex

### Changed
- Updated to R 4.5.1 from 4.4.1
- Removed pandoc-citeproc (deprecated)

## Earlier Versions

See git history for earlier changes.
