# Declare Ubuntu and Postgres versions
ARG UBUNTU_VERSION=20.04
ARG PG_VERSION
ARG OPENSSL_BUILDER_TAG

# OpenSSL Builder
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder

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
                       wget

# Postgres for Ubuntu 20.04 comes from a external repository
RUN wget https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
    apt-key add ACCC4CF8.asc && \
    echo "deb-src https://apt-archive.postgresql.org/pub/repos/apt focal-pgdg-archive main" >> /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get source postgresql-15=15.3-1.pgdg20.04+1

## Compile postgres client
RUN cd postgresql-$PG_VERSION && \
    env CC=gcc CPPFLAGS=-I/usr/local/ssl/include LDFLAGS=-L/usr/local/ssl/lib ./configure --with-ssl=openssl --without-readline --prefix=/usr/local/pgsql  && \
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
    make install
