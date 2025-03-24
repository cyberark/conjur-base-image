ARG UBI_VERSION

# ==============================================================================
# Ruby FIPS Builder
# ==============================================================================
FROM registry.access.redhat.com/$UBI_VERSION/ubi:latest AS ubi-ruby-fips-builder
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
# Conjur Base Image (UBI)
# ==============================================================================
FROM registry.access.redhat.com/$UBI_VERSION/ubi:latest AS ubi-ruby-fips-slim
ARG PG_VERSION
ARG RUBY_HOME=/var/lib/ruby

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    LANG=C.UTF-8 \
    PATH="${RUBY_HOME}/bin:${PATH}" \
    RUBY_HOME=${RUBY_HOME}

RUN dnf -y update && \
    dnf install -y --nodocs "https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-$(arch)/pgdg-redhat-repo-latest.noarch.rpm" && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then dnf list libpq5 | sed -n 's/^libpq5[^ ]* *\([0-9]*\)\.[0-9]*-.*$/\1/p'; else echo "${PG_VERSION%%.*}"; fi) && \
    dnf -qy module disable ruby && \
    dnf install -y --nodocs \
      patch \
      openldap-clients \
      tzdata \
      xz \
      "postgresql${PG_MAJOR_VERSION}-${PG_VERSION:=$PG_MAJOR_VERSION}*" && \
    dnf erase -y pgdg-redhat-repo && \
    dnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf /var/lib/dnf && \
    # Previously, this was created when installing libpq5 separately. Using
    # postgresql15-libs, this symlink isn't created, but is still necessary.
    ln -s /usr/lib64/libssl.so.3 /usr/lib64/libssl.so


# Copy ruby binaries from ubi-ruby-fips-builder
RUN mkdir -p "${RUBY_HOME}"
COPY --from=ubi-ruby-fips-builder ${RUBY_HOME} ${RUBY_HOME}

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
FROM ubi-ruby-fips-slim AS ubi-ruby-builder

RUN dnf -y update && \
    dnf install -y --nodocs \
      "https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-$(arch)/pgdg-redhat-repo-latest.noarch.rpm" && \
    export PG_MAJOR_VERSION=$(if [ -z "${PG_VERSION}" ]; then dnf list libpq5 | sed -n 's/^libpq5[^ ]* *\([0-9]*\)\.[0-9]*-.*$/\1/p'; else echo "${PG_VERSION%%.*}"; fi) && \
    dnf -qy module disable ruby && \
    dnf install -y --nodocs --nobest \
        gcc \
        gcc-c++ \
        git \
        glibc-devel \
        libxml2-devel \
        libxslt-devel \
        postgresql${PG_MAJOR_VERSION}-devel \
        make && \
    dnf erase -y pgdg-redhat-repo && \
    dnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf /var/lib/dnf && \
    # Tell bundler where to find the Postgresql dev dependencies when building
    # the `pg` gem.
    bundle config build.pg \
        --with-pg-lib=/usr/pgsql-${PG_MAJOR_VERSION}/lib \
        --with-pg-include=/usr/pgsql-${PG_MAJOR_VERSION}/include

# ==============================================================================
# Conjur Base Image (UBI) with dev tooling
# ==============================================================================
FROM ubi-ruby-fips-slim AS ubi-ruby-fips-dev

RUN dnf -y update && \
    dnf install -y --nodocs \
      jq \
      nano \
      vim && \
    dnf clean all && \
    rm -rf /var/cache/yum /var/cache/dnf /var/lib/dnf
