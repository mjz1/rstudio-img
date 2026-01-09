.PHONY: help build build-4.3 build-4.4 build-4.5 build-all up down restart logs clean lint pr-validate

# Default target
help:
	@echo "RStudio Image Development Commands"
	@echo "===================================="
	@echo ""
	@echo "Docker Compose commands:"
	@echo "  make up           - Start RStudio container"
	@echo "  make down         - Stop RStudio container"
	@echo "  make restart      - Restart RStudio container"
	@echo "  make logs         - View container logs"
	@echo ""
	@echo "Build commands:"
	@echo "  make build        - Build image with default R version (4.5)"
	@echo "  make build-4.3    - Build image with R 4.3"
	@echo "  make build-4.4    - Build image with R 4.4"
	@echo "  make build-4.5    - Build image with R 4.5"
	@echo "  make build-all    - Build images for R 4.3, 4.4, 4.5"
	@echo "  make pr-validate  - Run lint and build-all (mirrors CI PR build)"
	@echo ""
	@echo "Test commands:"
	@echo "  make lint         - Run linters (hadolint + shellcheck)"
	@echo ""
	@echo "Cleanup commands:"
	@echo "  make clean        - Remove built images and containers"

# Docker Compose commands
up:
	docker-compose up -d
	@echo "RStudio Server available at http://localhost:8787"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

# Build commands
build:
	docker build --platform linux/amd64 --build-arg R_VERSION=4.5 -t rstudio-local:4.5 .

build-4.3:
	docker build --platform linux/amd64 --build-arg R_VERSION=4.3 -t rstudio-local:4.3 .

build-4.4:
	docker build --platform linux/amd64 --build-arg R_VERSION=4.4 -t rstudio-local:4.4 .

build-4.5:
	docker build --platform linux/amd64 --build-arg R_VERSION=4.5 -t rstudio-local:4.5 .

# Build all supported R versions
build-all:
	$(MAKE) build-4.3
	$(MAKE) build-4.4
	$(MAKE) build-4.5

# Lint commands
lint:
	@echo "Linting Dockerfile..."
	@hadolint Dockerfile || echo "hadolint not installed. Install with: brew install hadolint"
	@echo ""
	@echo "Linting shell scripts..."
	@shellcheck install_quarto_latest.sh || echo "shellcheck not installed. Install with: brew install shellcheck"

# Run the same steps as PR validation locally
pr-validate:
	$(MAKE) lint
	$(MAKE) build-all

# Cleanup
clean:
	docker-compose down -v
	docker rmi rstudio-local:4.3 rstudio-local:4.4 rstudio-local:4.5 2>/dev/null || true
	@echo "Cleanup complete"
