# Declare Ubuntu and Postgres versions
ARG PG_VERSION=12-12.2
ARG UBUNTU_VERSION=20.04
ARG UBUNTU_FIPS_VERSION=18.04

# OpenSSL Builder
FROM registry.tld/ubuntu-fips:$UBUNTU_FIPS_VERSION as OpenSSL-builder

# Postgres Builder
FROM ubuntu:$UBUNTU_VERSION
ARG PG_VERSION

ENV LD_LIBRARY_PATH="/usr/local/ssl/lib"

COPY --from=OpenSSL-builder /usr/local/ssl/ /usr/local/ssl/

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y build-essential \
                       libreadline-dev \
                       gcc \
                       make \
                       zlib1g-dev \
                       dpkg-dev \
                       wget && \
    apt-get source libpq-dev

## Compile postgres client
RUN cd postgresql-$PG_VERSION && \
    env CC=gcc CPPFLAGS=-I/usr/local/ssl/include LDFLAGS=-L/usr/local/ssl/lib ./configure --with-openssl --without-readline --prefix=/usr/local/pgsql  && \
    cd - && \
    cd postgresql-$PG_VERSION/src/interfaces && \
    make && \
    make install && \
    cd - && \
    cd postgresql-$PG_VERSION/src/bin && \
    make && \
    make install && \
    cd - && \
    cd postgresql-$PG_VERSION/src/include && \
    make && \
    make install && \
    cd -
