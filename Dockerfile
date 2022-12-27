FROM rocker/rstudio:4.2.2

RUN apt-get update -qq && apt-get -y install \
      libbz2-dev \
      liblzma-dev \
      libxml2-dev \
      libcairo2-dev \
      libgit2-dev \
      default-libmysqlclient-dev \
      libpq-dev \
      libsasl2-dev \
      libsqlite3-dev \
      libssh2-1-dev \
      libxtst6 \
      libxt6 \
      libcurl4-openssl-dev \
      unixodbc-dev \
      build-essential && \
  rm -rf /var/lib/apt/lists/*

RUN R -e 'update.packages(ask=F)'