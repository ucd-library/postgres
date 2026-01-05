ARG PG_VERSION
ARG PLV8_VERSION

# Build stage for plv8 using raw Debian
FROM debian:bookworm-slim AS plv8-builder

ARG PG_VERSION
ARG PLV8_VERSION

# Install PostgreSQL APT repository
RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        gnupg \
      && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
      && echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install build dependencies
RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        postgresql-server-dev-${PG_VERSION} \
        build-essential \
        pkg-config \
        libstdc++-12-dev \
        cmake \
        git \
      && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/plv8/plv8.git --branch v${PLV8_VERSION} --single-branch && \
  cd /plv8 && \
  make && \
  make install

# Main stage
FROM postgres:${PG_VERSION}

ARG PG_VERSION
ENV PG_VERSION=${PG_VERSION}

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
        postgis \
        postgresql-${PG_VERSION}-postgis-3 \
        postgresql-${PG_VERSION}-postgis-3-scripts \
        postgresql-${PG_VERSION}-cron \
        libstdc++-12-dev \
      && rm -rf /var/lib/apt/lists/*

# Copy plv8 binaries from the build stage
COPY --from=plv8-builder /usr/lib/postgresql/${PG_VERSION}/lib/plv8*.so /usr/lib/postgresql/${PG_VERSION}/lib/
COPY --from=plv8-builder /usr/share/postgresql/${PG_VERSION}/extension/plv8* /usr/share/postgresql/${PG_VERSION}/extension/

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sql /docker-entrypoint-initdb.d/postgis.sql

ENV POSTGRES_HOST_AUTH_METHOD=password
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_USER=postgres
ENV POSTGIS_ENABLE_OUTDB_RASTERS=1
ENV POSTGIS_GDAL_ENABLED_DRIVERS=ENABLE_ALL