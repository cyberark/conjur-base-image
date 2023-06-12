ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION} as fips-provider-builder

ENV DEBIAN_FRONTEND=noninteractive

ARG OPEN_SSL_FIPS_PROVIDER_VERSION
ARG OPEN_SSL_FIPS_PROVIDER_SHA256

COPY build_openssl_fips_provider.sh .
RUN ./build_openssl_fips_provider.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256
ARG BUNDLER_VERSION

COPY build_ruby.sh .
RUN ./build_ruby.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-fips-slim
ARG PG_VERSION

RUN apt-get update && \
  apt-get upgrade -y && \
	apt-get install -y \
    openssl \
    curl \
    patch \
    gnupg \
    ca-certificates  \
    libyaml-0-2 && \
  echo "deb http://apt.postgresql.org/pub/repos/apt $(grep -oP '(?<=UBUNTU_CODENAME\=)(.*)' /etc/os-release)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
  curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
  apt-get --purge autoremove -y gnupg && \
  apt-get update && \
  apt-get install -y "postgresql-client-${PG_VERSION%%.*}=${PG_VERSION}*" && \
	apt-get clean && \
  apt-mark hold ruby postgresql-client && \
	rm -rf /var/lib/apt/lists/*

COPY --from=ubuntu-ruby-builder /var/lib/ruby /var/lib/ruby
COPY --from=fips-provider-builder /usr/local/lib/fips.so /usr/local/lib/fips.so
COPY fips_mode.sh /usr/local/bin/fips_mode.sh

RUN /usr/local/bin/fips_mode.sh -a enable
ENV PATH="/var/lib/ruby/bin:${PATH}" \
    FIPS_MODE=1
RUN ruby --version && \
    irb --version && \
    gem --version && \
    bundler --version && \
    ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'

CMD irb

FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
	apt-get install -y jq && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*
