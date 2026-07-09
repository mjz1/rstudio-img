# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
