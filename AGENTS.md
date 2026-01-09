# AGENTS.md

This document provides guidelines for agentic coding assistants working on the rstudio-img repository, which builds a customized Docker image for RStudio with scientific computing packages.

## Build Commands

### Full Build
```bash
# Build the Docker image locally
docker build --platform linux/amd64 -t rstudio:v0.3 .

# Or use the provided build script
./build.sh
```

### Release Build (AMD64 only)
```

### Development Build (with cache mount)
```bash
# Use build cache for faster iterations
docker build --platform linux/amd64 --build-arg BUILDKIT_INLINE_CACHE=1 -t rstudio:dev .
```

## Test Commands

### Basic Build Test
```bash
# Test that the image builds successfully
docker build --platform linux/amd64 -t rstudio:test .

# Verify the image was created
docker images | grep rstudio
```

### Runtime Test
```bash
# Run the container to test basic functionality
docker run -d --name rstudio-test -p 8787:8787 rstudio:test

# Test R installation
docker exec rstudio-test R --version

# Test Quarto installation
docker exec rstudio-test quarto --version

# Clean up test container
docker stop rstudio-test && docker rm rstudio-test
```

### Package Verification Test
```bash
# Test key scientific packages are installed
docker run --rm rstudio:test R -e "library(ggplot2); library(dplyr); print('Core packages working')"

# Test system tools
docker run --rm rstudio:test bash -c "bowtie2 --version && cmake --version"
```

### Single Test Run (Package Installation)
```bash
# Test a specific package installation
docker run --rm rstudio:test R -e "install.packages('testthat'); library(testthat); print('Package installation works')"
```

## Lint Commands

### Dockerfile Linting
```bash
# Using hadolint (install with: brew install hadolint)
hadolint Dockerfile

# Or using docker-hadolint
docker run --rm -i hadolint/hadolint < Dockerfile
```

### Shell Script Linting
```bash
# Lint shell scripts with shellcheck
shellcheck build.sh install_quarto_latest.sh

# Fix common issues automatically
shellcheck -f diff build.sh | git apply
```

### YAML Linting (GitHub Actions)
```bash
# Lint GitHub Actions workflow
yamllint .github/workflows/build_push.yaml
```

## Code Style Guidelines

### Dockerfile Conventions

#### Layer Optimization
- Group related RUN commands to minimize layers
- Use `&&` to chain commands in single RUN statements
- Clean up package manager cache with `rm -rf /var/lib/apt/lists/*`

#### Package Installation
- Install system packages alphabetically when possible for consistency
- Group packages by category (dev tools, scientific libraries, etc.)
- Use specific version pins for critical packages when stability is required

#### Best Practices
```dockerfile
# Good: Chain commands to reduce layers
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Avoid: Multiple RUN commands
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
```

#### Security Considerations
- Run as non-root user when possible
- Use trusted base images (rocker/rstudio)
- Avoid installing unnecessary packages
- Keep base image updated

### Shell Script Conventions

#### Script Structure
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Functions first
install_quarto() {
    # Implementation
}

# Main execution
main() {
    install_quarto
}

# Call main function
main "$@"
```

#### Error Handling
- Use `set -euo pipefail` at script start
- Check command success with `||` for critical operations
- Provide meaningful error messages

#### Naming Conventions
- Functions: `snake_case` (e.g., `install_quarto_latest`)
- Variables: `UPPER_SNAKE_CASE` for constants, `lower_snake_case` for variables
- Scripts: `descriptive_name.sh`

### Git and Commit Conventions

#### Commit Messages
```
feat: add CUDA development support
fix: correct Quarto installation URL parsing
docs: update README with Docker Hub link
chore: reorganize package installation order
```

#### Branch Naming
- Feature branches: `feature/add-cuda-support`
- Bug fixes: `fix/quarto-install-issue`
- Releases: `release/v1.2.3`

#### Pull Request Guidelines
- Include description of changes and testing performed
- Reference related issues
- Ensure CI passes before merging

### General Code Quality

#### File Organization
- Keep scripts in root directory if simple
- Use descriptive filenames
- Add comments for complex operations

#### Dependencies
- Prefer official packages from Ubuntu repositories
- Use latest stable versions unless compatibility issues exist
- Document version requirements in comments

#### Documentation
- Update README.md for user-facing changes
- Add inline comments for complex logic
- Document script purposes and usage

### Type Safety and Validation

#### Dockerfile Validation
- Test image builds successfully
- Verify installed packages are accessible
- Check file permissions are correct

#### Script Validation
- Test scripts in isolation
- Verify error handling works
- Check that cleanup operations succeed

### Error Handling Patterns

#### Dockerfile Error Handling
```dockerfile
# Check installation success
RUN apt-get install -y package-name || (echo "Failed to install package-name" && exit 1)

# Verify critical tools
RUN command -v important-tool || (echo "important-tool not found" && exit 1)
```

#### Script Error Handling
```bash
#!/bin/bash
set -euo pipefail

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Use throughout script
wget "$URL" || error_exit "Failed to download from $URL"
```

### Security Guidelines

#### Container Security
- Run containers as non-root when possible
- Use minimal base images
- Regularly update base image versions
- Avoid storing secrets in Docker layers

#### Script Security
- Validate input URLs and file paths
- Use HTTPS for downloads
- Verify checksums when available
- Avoid shell injection vulnerabilities

### Performance Considerations

#### Build Optimization
- Use multi-stage builds for complex applications
- Leverage Docker layer caching
- Minimize context size

#### Runtime Optimization
- Remove unnecessary packages after installation
- Use appropriate base images
- Configure containers for intended use case

### Testing Strategy

#### Automated Testing
- GitHub Actions runs on releases
- Manual testing for complex changes
- Verify package installations work
- Test container startup and basic functionality

#### Manual Testing Checklist
- [ ] Image builds without errors
- [ ] Container starts successfully
- [ ] RStudio interface loads
- [ ] Key packages are available
- [ ] Quarto is installed and functional
- [ ] System tools work (git, cmake, etc.)

This guide ensures consistent development practices for maintaining the rstudio-img Docker image repository.