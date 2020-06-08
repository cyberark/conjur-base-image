# Declare Ubuntu and Ruby versions
ARG RUBY_MAJOR_VERSION=2.5
ARG RUBY_FULL_VERSION=2.5.1
ARG BUNDLER_VERSION=2.1.4
ARG PHUSION_VERSION=0.11
ARG UBUNTU_FIPS_VERSION=18.04

# OpenSSL Builder
FROM registry.tld/ubuntu-fips:$UBUNTU_FIPS_VERSION as OpenSSL-builder

# Ruby Builder
FROM phusion/baseimage:$PHUSION_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG RUBY_SHA256=dac81822325b79c3ba9532b048c2123357d3310b2b40024202f360251d9829b1

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

## Compile Ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --with-openssl-dir=/usr/local/ssl --prefix=/var/lib/ruby && \
    make -j4 && \
    make install
