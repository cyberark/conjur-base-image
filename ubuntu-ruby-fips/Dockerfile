ARG UBUNTU_VERSION
ARG OPENSSL_BUILDER_TAG
ARG PG_BUILDER_TAG

# OpenSSL and postgres-client Builders
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder
FROM postgres-client-builder:$PG_BUILDER_TAG as postgres-client-builder

# ==============================================================================
# Ruby FIPS Builder
# ==============================================================================
FROM ubuntu:$UBUNTU_VERSION as ubuntu-ruby-fips-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256

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

## Compile ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --with-openssl-dir=/usr/local/ssl --prefix=/var/lib/ruby && \
    make -j4 && \
    make install

# ==============================================================================
# Conjur Base Image (Ubuntu)
# ==============================================================================
FROM ubuntu:$UBUNTU_VERSION as ubuntu-ruby-fips-slim
ARG BUNDLER_VERSION

### We need libreadline-dev for its readline capabilities
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y libreadline-dev

RUN apt-get purge -y --auto-remove openssl libssl1.1

# Install the FIPS compliant OpenSSL
## Copy to binary from openssl builder
COPY --from=OpenSSL-builder /usr/local/ssl/ /usr/local/ssl/
COPY --from=OpenSSL-builder /usr/share/ca-certificates/ /usr/share/ca-certificates/
COPY --from=OpenSSL-builder /etc/ssl/certs/ /etc/ssl/certs/
RUN rm -rf /usr/local/ssl/certs
RUN ln -sf /etc/ssl/certs/ /usr/local/ssl/

## Mock openssl and libssl
COPY --from=openSSL-builder /ca-certificates_*_all.deb /
COPY --from=openSSL-builder /openssl_*_all.deb /
COPY --from=openSSL-builder /libssl1.0.0_*_all.deb /

RUN dpkg -i ca-certificates_*_all.deb
RUN dpkg -i openssl_*_all.deb
RUN dpkg -i libssl1.0.0_*_all.deb

## Prevent openssl and libssl package from being automatically installed, upgraded or remove
RUN apt-mark hold ca-certificates
RUN apt-mark hold openssl
RUN apt-mark hold libssl1.0.0
RUN apt-mark hold libssl1.1

## Copy postgres and ruby binaries from fips-artifacts
RUN mkdir -p /var/lib/pgsql/ /var/lib/ruby/
COPY --from=postgres-client-builder /usr/local/pgsql/ /usr/local/pgsql/
COPY --from=ubuntu-ruby-fips-builder /var/lib/ruby/ /var/lib/ruby/

ENV PATH="/usr/local/pgsql/bin:/var/lib/ruby/bin:/usr/local/ssl/bin:${PATH}" \
    DEBIAN_FRONTEND=noninteractive \
    LD_LIBRARY_PATH="/usr/local/ssl/lib" \
    OPENSSL_FIPS=1

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION

# ==============================================================================
# Ruby Builder
# ==============================================================================
FROM ubuntu-ruby-fips-slim as ubuntu-ruby-builder

RUN apt-get update && \
    apt-get install -y libz-dev
RUN apt-get install -y git build-essential

# ==============================================================================
# Conjur Base Image (Ubuntu) with dev tooling
# ==============================================================================
FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

# ==============================================================================
# Tool 'setuser' Builder
# ==============================================================================
FROM golang:1.19 as setuser-builder
WORKDIR /src
COPY ./setuser /src
RUN go build .

# ==============================================================================
# Conjur Base Image (Ubuntu) with postgres server
# ==============================================================================
FROM ubuntu:$UBUNTU_VERSION as ubuntu-ruby-postgres-fips
ARG BUNDLER_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
      libreadline-dev \
      libdbd-pgsql \
      keyutils \
      slapd \
      ldap-utils \
      logrotate \
      runit \
      libarchive13 \
      cron

COPY runit /etc/service/
COPY --from=setuser-builder /src/setuser /sbin/setuser

RUN apt-get purge -y --auto-remove openssl libssl1.1 libldap-2.4.2
# Install the FIPS compliant OpenSSL
## Copy to binary from openssl builder
COPY --from=OpenSSL-builder /usr/local/ssl/ /usr/local/ssl/
COPY --from=OpenSSL-builder /usr/share/ca-certificates/ /usr/share/ca-certificates/
COPY --from=OpenSSL-builder /etc/ssl/certs/ /etc/ssl/certs/
RUN rm -rf /usr/local/ssl/certs
RUN ln -sf /etc/ssl/certs/ /usr/local/ssl/

## Mock openssl and libssl
COPY --from=openSSL-builder /ca-certificates_*_all.deb /
COPY --from=openSSL-builder /openssl_*_all.deb /
COPY --from=openSSL-builder /libssl1.0.0_*_all.deb /

RUN dpkg -i ca-certificates_*_all.deb
RUN dpkg -i openssl_*_all.deb
RUN dpkg -i libssl1.0.0_*_all.deb

## Prevent openssl and libssl package from being automatically installed, upgraded or removed
RUN apt-mark hold ca-certificates
RUN apt-mark hold openssl
RUN apt-mark hold libssl1.0.0
RUN apt-mark hold libssl1.1

# Install SASL dependency for OpenLDAP
RUN apt-get install -y libsasl2-dev && \
    apt-mark hold libssl1.1

## Copy postgres and ruby binaries from builders
RUN mkdir -p /var/lib/pgsql/ /var/lib/ruby/
COPY --from=postgres-client-builder /usr/local/pgsql/ /usr/local/pgsql/
COPY --from=ubuntu-ruby-fips-builder /var/lib/ruby/ /var/lib/ruby/

RUN ln -s /usr/local/ssl/bin/openssl /usr/bin/

ENV PATH="/usr/local/openldap/bin:/usr/local/pgsql/bin:/var/lib/ruby/bin:/usr/local/ssl/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/ssl/lib" \
    OPENSSL_FIPS=1

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION
