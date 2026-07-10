ARG R_VERSION=4.6

FROM rocker/rstudio:${R_VERSION}

# Set shell to use pipefail for safer pipe operations
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    automake \
    bowtie2 \
    bwidget \
    cargo \
    cmake \
    coinor-libclp-dev \
    dcraw \
    default-jdk \
    gdal-bin \
    git \
    gsfonts \
    haveged \
    imagej \
    imagemagick \
    jags \
    libapparmor-dev \
    libarchive-dev \
    libcairo2-dev \
    libcurl4-openssl-dev \
    libfftw3-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgdal-dev \
    libgeos-dev \
    libgit2-dev \
    libgl1-mesa-dev \
    libglib2.0-dev \
    libglpk-dev \
    libglu1-mesa-dev \
    libgmp3-dev \
    libgpgme11-dev \
    libgsl0-dev \
    libharfbuzz-dev \
    libhdf5-dev \
    libhiredis-dev \
    libicu-dev \
    libimage-exiftool-perl \
    libjpeg-dev \
    libjq-dev \
    libleptonica-dev \
    libmagic-dev \
    libmagick++-dev \
    libmpfr-dev \
    libmysqlclient-dev \
    libnetcdf-dev \
    libnode-dev \
    libopenmpi-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libpq-dev \
    libproj-dev \
    libprotobuf-dev \
    libquantlib0-dev \
    librsvg2-dev \
    libsasl2-dev \
    libsecret-1-dev \
    libsndfile1-dev \
    libsodium-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libssl-dev \
    libtesseract-dev \
    libtiff-dev \
    libudunits2-dev \
    libwebp-dev \
    libxft-dev \
    libxml2-dev \
    libxslt-dev \
    libzmq3-dev \
    make \
    ocl-icd-opencl-dev \
    pandoc \
    pari-gp \
    perl \
    pkg-config \
    protobuf-compiler \
    python3 \
    rustc \
    saga \
    tcl \
    tesseract-ocr-eng \
    texlive \
    tk \
    tk-dev \
    tk-table \
    unixodbc-dev \
    zlib1g-dev \
    build-essential \
    curl \
    wget \
    less \
    vim \
    libssh-dev \
    nvidia-cuda-dev \
    && R CMD javareconf \
    && rm -rf /var/lib/apt/lists/*

# Upgrade RStudio Server beyond the version pinned in the rocker base image.
# Rocker freezes the RStudio version at whatever was current when an R version
# was last built (e.g. the R 4.3 base ships RStudio from Dec 2023).
# RSTUDIO_VERSION accepts a release channel (stable, preview, daily) or an
# exact version like 2026.06.0+242 (CI passes the resolved current version so
# new RStudio releases invalidate the build cache).
ARG RSTUDIO_VERSION=stable
# hadolint ignore=DL3008
RUN . /etc/os-release && \
    case "${RSTUDIO_VERSION}" in \
      stable|preview|daily) \
        DEB_URL="https://rstudio.org/download/latest/${RSTUDIO_VERSION}/server/${UBUNTU_CODENAME}/rstudio-server-latest-amd64.deb" ;; \
      *) \
        # Posit only publishes jammy debs (the noble channel URL redirects to jammy)
        if [ "${UBUNTU_CODENAME}" = "noble" ]; then UBUNTU_CODENAME="jammy"; fi && \
        DEB_URL="https://download2.rstudio.org/server/${UBUNTU_CODENAME}/amd64/rstudio-server-${RSTUDIO_VERSION//+/-}-amd64.deb" ;; \
    esac && \
    curl -fsSL "${DEB_URL}" -o /tmp/rstudio-server.deb && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends /tmp/rstudio-server.deb && \
    rm -f /tmp/rstudio-server.deb && \
    rm -rf /var/lib/apt/lists/* && \
    rstudio-server version

# Replay the post-install fixups from rocker's install_rstudio.sh. Reinstalling
# the deb above re-runs its postinst, which undoes them.
#
# 1. The postinst generates a secure-cookie-key. Baked into a published image it
#    becomes a shared secret: every puller gets the same key and can forge
#    RStudio auth cookies. Rocker deletes it so it is regenerated on first run.
#    See https://github.com/rocker-org/rocker-versioned2/issues/137
# 2. The postinst writes database.conf 0600 root:root, since it may hold a
#    Postgres password. RStudio Server 2026.06+ treats an unreadable
#    database.conf as fatal (2025.09 ignored it), which breaks every rootless
#    runtime -- Singularity/Apptainer on HPC, `podman run --user`, OpenShift.
#    Write it explicitly with no secrets in it, so widening it leaks nothing.
# 3. Log to stderr, not syslog. There is no syslog socket in a container, so
#    rserver startup failures are discarded and the only symptom is the port
#    never opening. (Rocker's script says "# Log to stderr" and then sets
#    syslog -- the comment records the intent.)
RUN rm -f /var/lib/rstudio-server/secure-cookie-key && \
    printf 'provider=sqlite\ndirectory=/var/lib/rstudio-server\n' > /etc/rstudio/database.conf && \
    chmod 0644 /etc/rstudio/database.conf && \
    printf '[*]\nlog-level=warn\nlogger-type=stderr\n' > /etc/rstudio/logging.conf

# Update quarto to the latest release
COPY install_quarto_latest.sh /scripts/install_quarto_latest.sh

RUN chmod +x /scripts/install_quarto_latest.sh && \
    /scripts/install_quarto_latest.sh

# Setup tinytex with retry logic
RUN for attempt in {1..3}; do \
      echo "Attempt $attempt: Installing TinyTeX..." && \
      quarto install tool tinytex && break || \
      echo "Attempt $attempt failed, retrying in 5 seconds..." && \
      sleep 5; \
    done

# Setup git-lfs
# hadolint ignore=DL3008
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    apt-get install -y --no-install-recommends git-lfs && \
    rm -rf /var/lib/apt/lists/*

# Update R packages, and enable the in-IDE AI assistants.
#
# The two Posit Assistant options have opposite defaults, so the one that reads
# like the switch is not the one that gates the feature:
#
#   posit-assistant-enabled  default 1   integration *may* be enabled
#   allow-posit-assistant    default 0   use of the feature is *allowed*  <-- gate
#
# Neither sends anything anywhere on its own: the assistant fetches its agent
# from cdn.posit.co on first use and requires the user to sign in to Posit AI.
#
# rsession treats an unrecognised option in rsession.conf as fatal, and Posit
# Assistant only exists in RStudio Server >= 2026.04. Probe the binary for the
# option rather than assume, so a build pinned to an older RSTUDIO_VERSION still
# produces a working image instead of one whose sessions refuse to start.
RUN R -e 'update.packages(ask=F)' && \
    echo 'copilot-enabled=1' >> /etc/rstudio/rsession.conf && \
    if grep -aq 'allow-posit-assistant' /usr/lib/rstudio-server/bin/rsession; then \
      printf 'posit-assistant-enabled=1\nallow-posit-assistant=1\n' >> /etc/rstudio/rsession.conf && \
      echo "Posit Assistant: enabled"; \
    else \
      echo "Posit Assistant: unsupported by this RStudio Server build, skipping"; \
    fi && \
    cat /etc/rstudio/rsession.conf

# Add image metadata labels
LABEL org.opencontainers.image.title="RStudio Server with Scientific Computing Packages" \
      org.opencontainers.image.description="RStudio Server (AMD64) with comprehensive scientific computing libraries" \
      org.opencontainers.image.source="https://github.com/mjz1/rstudio-img" \
      org.opencontainers.image.vendor="zatzmanm" \
      org.opencontainers.image.documentation="Built for AMD64. Runs via emulation on ARM64 hosts."
