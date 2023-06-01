ARG UBUNTU_VERSION=22.04
# ARG OPENSSL_BUILDER_TAG
# ARG PG_BUILDER_TAG
# ARG BUNDLER_VERSION=2.2.33

FROM ubuntu:${UBUNTU_VERSION} as fips-provider-builder

ARG OPEN_SSL_FIPS_PROVIDER_VERSION=3.0.0

RUN apt-get update && \
	apt-get install -y curl build-essential checkinstall zlib1g-dev
COPY build_openssl_fips_provider.sh .
RUN ./build_openssl_fips_provider.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-builder
ARG RUBY_FULL_VERSION=3.0.6
ARG RUBY_MAJOR_VERSION=3.0
ARG RUBY_SHA256=6e6cbd490030d7910c0ff20edefab4294dfcd1046f0f8f47f78b597987ac683e

COPY build_ruby.sh .
RUN ./build_ruby.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-fips-slim
ARG RUBY_FULL_VERSION=3.0.6

RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get install -y openssl curl && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY --from=ubuntu-ruby-builder /usr/bin/* /usr/bin/

COPY --from=fips-provider-builder /usr/local/lib/fips.so /usr/local/lib/fips.so

COPY enable_fips.sh /tmp/enable_fips.sh
RUN /tmp/enable_fips.sh

FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
	apt-get install -y postgresql-client && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


CMD ruby --version && openssl list --digest-commands -provider fips && openssl list --digest-commands && sleep infinity
