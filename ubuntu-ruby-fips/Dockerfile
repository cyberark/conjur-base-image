ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION} as fips-provider-builder

ARG OPEN_SSL_FIPS_PROVIDER_VERSION

COPY build_openssl_fips_provider.sh .
RUN ./build_openssl_fips_provider.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-builder
ARG RUBY_FULL_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_SHA256

COPY build_ruby.sh .
RUN ./build_ruby.sh

FROM ubuntu:${UBUNTU_VERSION} as ubuntu-ruby-fips-slim

RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get install -y openssl curl ca-certificates && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

COPY --from=ubuntu-ruby-builder /usr/local/ /usr/local/
COPY --from=fips-provider-builder /usr/local/lib/fips.so /usr/local/lib/fips.so
COPY enable_fips.sh /tmp/enable_fips.sh
RUN /tmp/enable_fips.sh
ENV PATH="/usr/local/bin:${PATH}"
#    OPENSSL_FIPS=1


FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
	apt-get install -y postgresql-client && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


CMD ruby --version && openssl list --digest-commands -provider fips && openssl list --digest-commands && sleep infinity
