# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
