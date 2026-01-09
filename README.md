# rstudio-img

Customized Docker images for RStudio Server with scientific computing packages, supporting multiple R versions.

[![Publish Docker images](https://github.com/zatzmanm/rstudio-img/actions/workflows/build_push.yaml/badge.svg)](https://github.com/zatzmanm/rstudio-img/actions/workflows/build_push.yaml)
[![PR Validation](https://github.com/zatzmanm/rstudio-img/actions/workflows/pr-validation.yaml/badge.svg)](https://github.com/zatzmanm/rstudio-img/actions/workflows/pr-validation.yaml)

## Docker Images

Available on:
- [Docker Hub](https://hub.docker.com/r/zatzmanm/rstudio/tags): `zatzmanm/rstudio`
- [GitHub Container Registry](https://github.com/mjz1/rstudio-img/pkgs/container/rstudio-img): `ghcr.io/mjz1/rstudio-img`

### Supported R Versions

- `zatzmanm/rstudio:4.3` or `ghcr.io/mjz1/rstudio-img:4.3` - Latest R 4.3.X
- `zatzmanm/rstudio:4.4` or `ghcr.io/mjz1/rstudio-img:4.4` - Latest R 4.4.X
- `zatzmanm/rstudio:4.5` or `ghcr.io/mjz1/rstudio-img:4.5` - Latest R 4.5.X
- `zatzmanm/rstudio:latest` or `ghcr.io/mjz1/rstudio-img:latest` - Points to R 4.5 (highest version)

### Versioned Releases

For each GitHub release (e.g., `v1.0.0`), the following additional tags are created on both registries:

- `v1.0.0` - Release snapshot
- `v1.0.0-r4.3` - Release + R 4.3
- `v1.0.0-r4.4` - Release + R 4.4  
- `v1.0.0-r4.5` - Release + R 4.5

## Prerequisites

- Docker Desktop or Docker Engine
- Docker Compose (for local development)
- 8GB+ RAM recommended
- 10GB+ disk space

## Quick Start

Run RStudio Server locally:

```bash
docker run -d -p 8787:8787 -e PASSWORD=yourpassword zatzmanm/rstudio:latest
```

Access at http://localhost:8787
- Username: `rstudio`
- Password: `yourpassword`

**Note:** Images are built for `linux/amd64` (AMD64/x86_64). Docker automatically handles emulation on `linux/arm64` (ARM64) hosts (e.g., Apple Silicon).

## Local Development

### Using Docker Compose (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/zatzmanm/rstudio-img.git
   cd rstudio-img
   ```

2. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` to configure your setup:
   ```bash
   # R version (4.3, 4.4, or 4.5)
   R_VERSION=4.5
   
   # RStudio credentials
   RSTUDIO_USER=rstudio
   RSTUDIO_PASSWORD=yourpassword
   ```

4. Start the container:
   ```bash
   docker-compose up -d
   ```

5. Access RStudio at http://localhost:8787

The `./work` and `./data` directories are automatically mounted for persistent storage.

### Using Makefile

For convenience, use the provided Makefile:

```bash
# View all available commands
make help

# Start RStudio Server
make up

# View logs
make logs

# Build specific R version
make build-4.5

# Run tests
make test

# Lint code
make lint

# Stop and cleanup
make down
```

### Manual Build

Build for a specific R version:

```bash
docker build --build-arg R_VERSION=4.5 -t rstudio-local:4.5 .
```

Run the built image:

```bash
docker run -d -p 8787:8787 -e PASSWORD=rstudio rstudio-local:4.5
```

## Included Packages

### Scientific Computing
- Statistical packages (base R, recommended packages)
- Data manipulation (tidyverse ecosystem ready)
- Machine learning libraries support
- Bioinformatics tools (Bowtie2, etc.)

### Development Tools
- Git + Git LFS
- CMake, Make, Automake
- Compilers (GCC, Rust, Cargo)
- Python 3

### Document Publishing
- Quarto (latest version)
- TinyTeX (LaTeX distribution)
- Pandoc

### Hardware Acceleration
- CUDA development tools
- OpenCL support

### GIS and Spatial Analysis
- GDAL, PROJ, GEOS
- Spatial data libraries

### Databases
- PostgreSQL, MySQL clients
- SQLite support

### And Many More...
See the [Dockerfile](Dockerfile) for the complete list of installed packages.

## Architecture Support

Images are built for `linux/amd64` (Intel/AMD 64-bit) with full support for all packages including CUDA and TinyTeX.

### Running on ARM64 (Apple Silicon)

Docker automatically uses emulation (Rosetta) to run AMD64 images on ARM64 hosts:
- Performance is excellent for most R/RStudio workloads
- Docker Desktop handles emulation transparently
- The `docker-compose.yml` configuration automatically specifies the correct platform
- No manual configuration needed for Apple Silicon Macs

### Why AMD64 Only?

These images are designed primarily for server deployments where consistency and identical behavior across all environments is critical. Building for a single architecture ensures:
- Identical package versions and behavior everywhere
- No architecture-specific bugs or differences
- Simplified maintenance and testing
- Faster CI/CD build times (~2-3x improvement)

For users who need native ARM64 performance for local development, we may provide optimized ARM64 builds in the future. The current AMD64 images work well via emulation for most use cases.

## Versioning Strategy

- **R Version Tags**: `rstudio:4.3`, `rstudio:4.4`, `rstudio:4.5` - Always point to the latest build for each R major version
- **Latest Tag**: `rstudio:latest` - Always points to the highest R version (currently 4.5)
- **Release Tags**: For each GitHub release `vX.Y.Z`, creates versioned snapshots like `rstudio:v1.0.0-r4.5`
- Uses latest available rocker/rstudio tags for each major R version
- Release tags preserve build history for reproducible deployments

## Troubleshooting

### Running on Apple Silicon (M1/M2/M3)

Images are AMD64 and run via emulation on Apple Silicon:
- Docker Desktop handles emulation automatically via Rosetta
- Performance is excellent for R/RStudio workloads (typically <10% overhead)
- Use `docker-compose up` - platform is pre-configured in docker-compose.yml
- First launch may take slightly longer as emulation initializes
- If you experience issues, ensure Rosetta emulation is enabled in Docker Desktop settings (Preferences → Features in Development → Use Rosetta for x86/amd64 emulation)

### Port Already in Use

If port 8787 is already in use:
```bash
# Use a different port
docker run -d -p 8888:8787 -e PASSWORD=rstudio zatzmanm/rstudio:latest
# Access at http://localhost:8888
```

### Permission Issues with Mounted Volumes

Ensure the `work` and `data` directories exist and have proper permissions:
```bash
mkdir -p work data
chmod 755 work data
```

### Container Won't Start

Check logs:
```bash
docker-compose logs
# or
docker logs rstudio-dev
```

## Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run linters: `make lint`
5. Build and test locally: `make build && make test`
6. Submit a pull request

### Code Standards

- Follow Dockerfile best practices
- Use `shellcheck` for shell scripts
- Test changes with all R versions (4.3, 4.4, 4.5)
- Update CHANGELOG.md for notable changes

### Adding New R Versions

To add support for a new R version:

1. Update the matrix in `.github/workflows/build_push.yaml`
2. Update the matrix in `.github/workflows/pr-validation.yaml`
3. Update README.md documentation
4. Update the "latest" tag logic if it's the new highest version

## CI/CD

### Automated Builds

Images are automatically built and pushed to Docker Hub:
- On GitHub releases (all R versions)
- On manual workflow dispatch

### PR Validation

Pull requests trigger:
- Dockerfile linting (hadolint)
- Shell script linting (shellcheck)  
- Test build for R 4.5
- Runtime test suite

### Testing

Each build includes:
- R version verification
- Package installation test
- Quarto rendering test
- System tools validation
- Scientific library checks

## License

See repository license file.

## Acknowledgments

Built on top of the excellent [Rocker Project](https://rocker-project.org/) images.

## Support

For issues and questions:
- GitHub Issues: https://github.com/zatzmanm/rstudio-img/issues
- Docker Hub: https://hub.docker.com/r/zatzmanm/rstudio
