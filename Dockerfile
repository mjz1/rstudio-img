ARG R_VERSION=4.5

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
    librdf0-dev \
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

# Update quarto to the latest release
COPY install_quarto_latest.sh /scripts/install_quarto_latest.sh
COPY scripts/test-runtime.sh /scripts/test-runtime.sh

RUN chmod +x /scripts/install_quarto_latest.sh /scripts/test-runtime.sh && \
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

# Update R packages and enable copilot
RUN R -e 'update.packages(ask=F)' && \
    echo 'copilot-enabled=1' >> /etc/rstudio/rsession.conf

# Add image metadata labels
LABEL org.opencontainers.image.title="RStudio Server with Scientific Computing Packages" \
      org.opencontainers.image.description="RStudio Server (AMD64) with comprehensive scientific computing libraries" \
      org.opencontainers.image.source="https://github.com/zatzmanm/rstudio-img" \
      org.opencontainers.image.vendor="zatzmanm" \
      org.opencontainers.image.documentation="Built for AMD64. Runs via emulation on ARM64 hosts."
