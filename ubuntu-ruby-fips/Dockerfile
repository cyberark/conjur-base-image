ARG UBUNTU_VERSION=24.04

# OPENSSL_FORCE_FIPS_MODE=0 on apt RUN only (CNJR-13114 / AmznDocker):
# - CI host AmznDocker enables kernel FIPS; Noble containers inherit
#   /proc/sys/crypto/fips_enabled and hit Ubuntu LP #2066990 during
#   update-ca-certificates ("out of memory" symptom).
# - main built on common-agent + ExecutorV2 (host FIPS off) and never
#   needed this override; do NOT bake it as ENV — that would diverge
#   shipped Config.Env from main and is not a product FIPS change.
# - Product FIPS for ubuntu-ruby-fips remains fips_init / openssl.cnf.
# See docs/building-on-fips-enabled-hosts.md

# ==============================================================================
# FIPS Provider builder
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} AS fips-provider-builder

ENV DEBIAN_FRONTEND=noninteractive

ARG OPEN_SSL_FIPS_PROVIDER_VERSION
ARG OPEN_SSL_FIPS_PROVIDER_SHA256

COPY ubuntu-ruby-fips/build_openssl_fips_provider.sh /
# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN OPENSSL_FORCE_FIPS_MODE=0 /build_openssl_fips_provider.sh

# ==============================================================================
# Ruby FIPS Builder
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} AS ubuntu-ruby-fips-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256
ARG BUNDLER_VERSION
ARG RUBY_HOME=/var/lib/ruby

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    LANG=C.UTF-8

COPY ubuntu-ruby-fips/build_ruby.sh /

COPY Gemfile Gemfile.lock /

# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN OPENSSL_FORCE_FIPS_MODE=0 /build_ruby.sh

# ==============================================================================
# Conjur Base Image (Ubuntu)
# ==============================================================================
FROM ubuntu:${UBUNTU_VERSION} AS ubuntu-ruby-fips-slim
ARG PG_VERSION
ARG RUBY_HOME=/var/lib/ruby

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    LANG=C.UTF-8 \
    PATH="${RUBY_HOME}/bin:${PATH}" \
    RUBY_HOME=${RUBY_HOME} \
    PG_VERSION=${PG_VERSION}

COPY ubuntu-ruby-fips/apt/ /etc/apt/
# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN OPENSSL_FORCE_FIPS_MODE=0 apt-get update && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get install -y gnupg && \
    for f in /etc/apt/keyrings/*.pub; do \
      file=$(basename -- "$f"); gpg --dearmor < "$f" > "/etc/apt/keyrings/${file%.*}.gpg"; rm "$f"; \
    done && \
    . /etc/os-release && \
    PG_MAJOR_VERSION=${PG_VERSION%%.*} && \
    # Component name differ for amd64 and arm64 architectures for Syslog-NG OSE
    COMPONENT_NAME=$(case $(dpkg --print-architecture) in \
      amd64) echo "$VERSION_CODENAME" ;; \
      arm64) echo "$VERSION_CODENAME-arm64" ;; \
      *) echo "" ;; \
    esac) && \
    for f in /etc/apt/sources.list.d/*.template; do \
      file=$(basename -- "$f"); while read line; do eval echo \"$line\"; done < "$f" > "/etc/apt/sources.list.d/${file%.*}.list"; rm "$f"; \
    done && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get update && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then apt-cache madison libpq5 | sed -n 's/^ *libpq5 *| *\([0-9]*\)\.[0-9]*-.*$/\1/p' | sort -Vr | head -1; else echo "${PG_VERSION%%.*}"; fi) && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get upgrade -y && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get install -y \
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

# Copy Gemfile and Gemfile.lock from ubuntu-ruby-fips-builder
COPY --from=ubuntu-ruby-fips-builder /Gemfile /Gemfile.lock /base/
COPY --from=ubuntu-ruby-fips-builder /usr/local/bundle /usr/local/bundle

COPY ubuntu-ruby-fips/fips_init ubuntu-ruby-fips/fips_mode /usr/local/bin/

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
FROM ubuntu-ruby-fips-slim AS ubuntu-ruby-builder

# We don't want FIPS mode on the builder since it disables bundler optimizations
ENV OPENSSL_CONF=/usr/lib/ssl/openssl_non_fips.cnf

# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN OPENSSL_FORCE_FIPS_MODE=0 apt-get update && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get install -y \
      git \
      build-essential \
      libreadline-dev \
      libz-dev \
      libsqlite3-dev \
      libsqlcipher-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

# ==============================================================================
# Conjur Base Image (Ubuntu) with dev tooling
# ==============================================================================
FROM ubuntu-ruby-fips-slim AS ubuntu-ruby-fips-dev

# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN OPENSSL_FORCE_FIPS_MODE=0 apt-get update && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get install -y \
      jq \
      vim \
      nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

# ==============================================================================
# Tool 'setuser' Builder
# ==============================================================================
FROM golang:latest AS setuser-builder

ENV GOFIPS140=latest

WORKDIR /src
COPY ubuntu-ruby-fips/setuser /src
RUN go test && \
    go build .

# ==============================================================================
# Timescaledb Tool Builder
# This step is needed to install latest
# version of the timescaledb-tune tool
# ==============================================================================
FROM golang:latest AS timescaledb-tool-builder

RUN go install github.com/timescale/timescaledb-tune/cmd/timescaledb-tune@latest

# ==============================================================================
# Conjur Base Image (Ubuntu) with postgres server
# ==============================================================================
FROM ubuntu-ruby-fips-dev AS ubuntu-ruby-postgres-fips
ARG PG_VERSION

# Host-FIPS apt workaround — see comment at top of file (do not use ENV).
RUN printf '%s\n' \
      # Prevent package manager from installing `timescaledb-tune` and `timescaledb-parallel-copy` \
      # As we later install `timescaledb-tune` manually from sources, we don't want the package manager \
      # to install it and cause a hash conflicts on security scans. \
      'path-exclude=/usr/bin/timescaledb-tune' \
      'path-exclude=/usr/bin/timescaledb-parallel-copy' \
      > /etc/dpkg/dpkg.cfg.d/excludes-timescaledb-tools && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get update && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then apt-cache madison libpq5 | sed -n 's/^ *libpq5 *| *\([0-9]*\)\.[0-9]*-.*$/\1/p' | sort -Vr | head -1; else echo "${PG_VERSION%%.*}"; fi) && \
    OPENSSL_FORCE_FIPS_MODE=0 apt-get install -y \
      "postgresql-${PG_MAJOR_VERSION}=${PG_VERSION}*" \
      "postgresql-${PG_MAJOR_VERSION}-pglogical" \
      "timescaledb-2-postgresql-${PG_MAJOR_VERSION}" \
      syslog-ng-core \
      syslog-ng-scl \
      syslog-ng-mod-sql \
      libreadline-dev \
      libdbd-pgsql \
      keyutils \
      slapd \
      ldap-utils \
      logrotate \
      runit \
      nginx \
      sudo \
      libarchive13 \
      cron \
      dnsmasq \
      # libcap2-bin is required for the `capsh`
      # command to check permitted capabilities
      libcap2-bin && \
    locale-gen en_US.UTF-8 && \
    # Uncomment the PATH environment variable from the system crontab so that
    # cron jobs can find the system executables.
    sed -i 's/^#PATH/PATH/' /etc/crontab && \
    # Disable the pam_loginuid.so PAM module for cron jobs. This is carried
    # forward from the Phusion base image and is required for cron jobs to run:
    # https://github.com/phusion/baseimage-docker/blob/master/image/services/cron/cron.sh#L10-L11
    sed -i 's/^\s*session\s\+required\s\+pam_loginuid.so/# &/' /etc/pam.d/cron && \
    # Register local diversions before replacing or removing package-owned files so scanners do not report md5sum mismatches \
    dpkg-divert --quiet --local --rename \
      --divert /usr/bin/timescaledb-tune.distrib \
      --add /usr/bin/timescaledb-tune && \
    dpkg-divert --quiet --local --rename \
      --divert /usr/bin/timescaledb-parallel-copy.distrib \
      --add /usr/bin/timescaledb-parallel-copy && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

COPY ubuntu-ruby-fips/runit /etc/service/
COPY --from=setuser-builder /src/setuser /sbin/setuser
COPY --from=timescaledb-tool-builder /go/bin/timescaledb-tune /usr/bin/timescaledb-tune
