ARG UBUNTU_VERSION

# ==============================================================================
# FIPS Provider builder
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} as fips-provider-builder

ENV DEBIAN_FRONTEND=noninteractive

ARG OPEN_SSL_FIPS_PROVIDER_VERSION
ARG OPEN_SSL_FIPS_PROVIDER_SHA256

COPY build_openssl_fips_provider.sh /
RUN /build_openssl_fips_provider.sh

# ==============================================================================
# Ruby FIPS Builder
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-fips-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256
ARG BUNDLER_VERSION
ARG RUBY_HOME=/var/lib/ruby

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    LANG=C.UTF-8

COPY build_ruby.sh /
RUN /build_ruby.sh

# ==============================================================================
# Conjur Base Image (Ubuntu)
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-fips-slim
ARG PG_VERSION
ARG RUBY_HOME=/var/lib/ruby

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    LANG=C.UTF-8 \
    PATH="${RUBY_HOME}/bin:${PATH}" \
    RUBY_HOME=${RUBY_HOME} \
    PG_VERSION=${PG_VERSION}

COPY apt/ /etc/apt/
RUN apt-get update && \
    apt-get install -y gnupg && \
    for f in /etc/apt/keyrings/*.pub; do \
      file=$(basename -- "$f"); gpg --dearmor < "$f" > "/etc/apt/keyrings/${file%.*}.gpg"; rm "$f"; \
    done && \
    . /etc/os-release && \
    PG_MAJOR_VERSION=${PG_VERSION%%.*} && \
    for f in /etc/apt/sources.list.d/*.template; do \
      file=$(basename -- "$f"); while read line; do eval echo \"$line\"; done < "$f" > "/etc/apt/sources.list.d/${file%.*}.list"; rm "$f"; \
    done

RUN apt-get update && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then apt-cache madison libpq5 | sed -n 's/^ *libpq5 *| *\([0-9]*\)\.[0-9]*-.*$/\1/p' | sort -Vr | head -1; else echo "${PG_VERSION%%.*}"; fi) && \
    apt-get upgrade -y && \
    apt-get install -y \
      openssl \
      curl \
      patch \
      ca-certificates \
      tzdata \
      xz-utils \
      netcat-openbsd \
      "libpq5=${PG_VERSION}*" \
      "libpq-dev=${PG_VERSION}*" \
      "postgresql-client-${PG_MAJOR_VERSION}*=${PG_VERSION}*" \
      libyaml-0-2 && \
    apt-get clean && \
    apt-mark hold ruby && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

# Copy ruby binaries from ubuntu-ruby-fips-builder
COPY --from=ubuntu-ruby-fips-builder ${RUBY_HOME} ${RUBY_HOME}
# Copy fips provider from fips-provider-builder
COPY --from=fips-provider-builder /usr/local/lib/fips.so /usr/local/lib/fips.so

COPY fips_init fips_mode /usr/local/bin/

# Enables FIPS mode for GnuPG
ENV LIBGCRYPT_FORCE_FIPS_MODE=1

RUN /usr/local/bin/fips_init && \
    rm /usr/local/bin/fips_init && \
    bundle config --global jobs "$(nproc --all)"

RUN ruby --version && \
    irb --version && \
    gem --version && \
    bundler --version && \
    ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'

CMD ["irb"]

# ==============================================================================
# Ruby Builder
# ==============================================================================
FROM ubuntu-ruby-fips-slim as ubuntu-ruby-builder

# We don't want FIPS mode on the builder since it disables bundler optimizations
ENV OPENSSL_CONF=/usr/lib/ssl/openssl_non_fips.cnf

RUN apt-get update && \
    apt-get install -y \
      git \
      build-essential \
      libreadline-dev \
      libz-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

# ==============================================================================
# Conjur Base Image (Ubuntu) with dev tooling
# ==============================================================================
FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
    apt-get install -y \
      jq \
      vim \
      nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

# ==============================================================================
# Tool 'setuser' Builder
# ==============================================================================
FROM golang:latest as setuser-builder
WORKDIR /src
COPY ./setuser /src
RUN go build .

# ==============================================================================
# Conjur Base Image (Ubuntu) with postgres server
# ==============================================================================
FROM ubuntu-ruby-fips-dev as ubuntu-ruby-postgres-fips
ARG PG_VERSION

RUN apt-get update && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then apt-cache madison libpq5 | sed -n 's/^ *libpq5 *| *\([0-9]*\)\.[0-9]*-.*$/\1/p' | sort -Vr | head -1; else echo "${PG_VERSION%%.*}"; fi) && \
    apt-get install -y \
      "postgresql-${PG_MAJOR_VERSION}=${PG_VERSION}*" \
      "postgresql-${PG_MAJOR_VERSION}-pglogical" \
      libreadline-dev \
      libdbd-pgsql \
      keyutils \
      slapd \
      ldap-utils \
      logrotate \
      runit \
      nginx \
      libarchive13 \
      cron \
      syslog-ng-core \
      syslog-ng-mod-sql && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

COPY runit /etc/service/
COPY --from=setuser-builder /src/setuser /sbin/setuser
