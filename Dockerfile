ARG PG_VERSION
FROM postgres:${PG_VERSION}

ARG PLV8_VERSION

ARG PG_VERSION
ENV PG_VERSION=${PG_VERSION}

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        postgis \
        postgresql-${PG_VERSION}-postgis-3 \
        postgresql-${PG_VERSION}-postgis-3-scripts \
        postgresql-server-dev-${PG_VERSION} \
        libtinfo5 \
        build-essential \
        pkg-config \
        libstdc++-12-dev \
        cmake \
        git \
        wget \
        ca-certificates \
      && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/plv8/plv8.git --branch v${PLV8_VERSION} --single-branch && \
  cd /plv8 && \
  make && \
  make install \
  rm -rf /plv8

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sql /docker-entrypoint-initdb.d/postgis.sql

ENV POSTGRES_HOST_AUTH_METHOD=password
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_USER=postgres
ENV POSTGIS_ENABLE_OUTDB_RASTERS=1
ENV POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL