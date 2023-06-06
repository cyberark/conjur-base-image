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

RUN apt-get update && \
  apt-get upgrade -y && \
	apt-get install -y \
    openssl \
    curl \
    ca-certificates  \
    libyaml-0-2 && \
	apt-get clean && \
  apt-mark hold ruby && \
	rm -rf /var/lib/apt/lists/*

COPY --from=ubuntu-ruby-builder /var/lib/ruby /var/lib/ruby
COPY --from=fips-provider-builder /usr/local/lib/fips.so /usr/local/lib/fips.so
COPY enable_fips.sh /tmp/enable_fips.sh
# we cannot enable the FIPS mod yet due to: https://github.com/openssl/openssl/issues/20657
#RUN /tmp/enable_fips.sh
ENV PATH="/var/lib/ruby/bin:${PATH}"
#    OPENSSL_FIPS=1
RUN ruby --version && \
    gem --version && \
    bundler --version


FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
	apt-get install -y postgresql-client && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN ruby -ropenssl -e 'puts OpenSSL::OPENSSL_VERSION'

#CMD ruby --version && openssl list --digest-commands -provider fips && openssl list --digest-commands && sleep infinity
CMD ruby --version && openssl list --digest-commands && sleep infinity
