FROM rocker/rstudio:4.2.2

RUN apt-get update -qq 
RUN apt-get install -y automake
RUN apt-get install -y bowtie2
RUN apt-get install -y bwidget
RUN apt-get install -y cargo
RUN apt-get install -y cmake
RUN apt-get install -y coinor-libclp-dev
RUN apt-get install -y dcraw
RUN apt-get install -y default-jdk
RUN apt-get install -y gdal-bin
RUN apt-get install -y git
RUN apt-get install -y gsfonts
RUN apt-get install -y haveged
RUN apt-get install -y imagej
RUN apt-get install -y imagemagick
RUN apt-get install -y jags
RUN apt-get install -y libapparmor-dev
RUN apt-get install -y libarchive-dev
RUN apt-get install -y libcairo2-dev
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libfftw3-dev
RUN apt-get install -y libfontconfig1-dev
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libfribidi-dev
RUN apt-get install -y libgdal-dev
RUN apt-get install -y libgeos-dev
RUN apt-get install -y libgit2-dev
RUN apt-get install -y libgl1-mesa-dev
RUN apt-get install -y libglib2.0-dev
RUN apt-get install -y libglpk-dev
RUN apt-get install -y libglu1-mesa-dev
RUN apt-get install -y libgmp3-dev
RUN apt-get install -y libgpgme11-dev
RUN apt-get install -y libgsl0-dev
RUN apt-get install -y libharfbuzz-dev
RUN apt-get install -y libhdf5-dev
RUN apt-get install -y libhiredis-dev
RUN apt-get install -y libicu-dev
RUN apt-get install -y libimage-exiftool-perl
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libjq-dev
RUN apt-get install -y libleptonica-dev
RUN apt-get install -y libmagic-dev
RUN apt-get install -y libmagick++-dev
RUN apt-get install -y libmpfr-dev
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y libnetcdf-dev
RUN apt-get install -y libnode-dev
RUN apt-get install -y libopenmpi-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libpoppler-cpp-dev
RUN apt-get install -y libpq-dev
RUN apt-get install -y libproj-dev
RUN apt-get install -y libprotobuf-dev
RUN apt-get install -y libquantlib0-dev
RUN apt-get install -y librdf0-dev
RUN apt-get install -y librsvg2-dev
RUN apt-get install -y libsasl2-dev
RUN apt-get install -y libsecret-1-dev
RUN apt-get install -y libsndfile1-dev
RUN apt-get install -y libsodium-dev
RUN apt-get install -y libsqlite3-dev
RUN apt-get install -y libssh2-1-dev
RUN apt-get install -y libssl-dev
RUN apt-get install -y libtesseract-dev
RUN apt-get install -y libtiff-dev
RUN apt-get install -y libudunits2-dev
RUN apt-get install -y libwebp-dev
RUN apt-get install -y libxft-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libxslt-dev
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y make
RUN apt-get install -y nvidia-cuda-dev
RUN apt-get install -y ocl-icd-opencl-dev
RUN apt-get install -y pandoc
RUN apt-get install -y pandoc-citeproc
RUN apt-get install -y pari-gp
RUN apt-get install -y perl
RUN apt-get install -y pkg-config
RUN apt-get install -y protobuf-compiler
RUN apt-get install -y python3
RUN apt-get install -y rustc
RUN apt-get install -y saga
RUN apt-get install -y tcl
RUN apt-get install -y tesseract-ocr-eng
RUN apt-get install -y texlive
RUN apt-get install -y tk
RUN apt-get install -y tk-dev
RUN apt-get install -y tk-table
RUN apt-get install -y unixodbc-dev
RUN apt-get install -y zlib1g-dev
RUN R CMD javareconf

RUN apt-get install -y build-essential
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y less
RUN apt-get install -y vim

# Setup tinytex
RUN quarto install tool tinytex 

# Update quarto to the latest release
COPY install_quarto_latest.sh /scripts/install_quarto_latest.sh

RUN chmod +x /scripts/install_quarto_latest.sh
RUN /scripts/install_quarto_latest.sh

RUN rm -rf /var/lib/apt/lists/*

RUN R -e 'update.packages(ask=F)'
