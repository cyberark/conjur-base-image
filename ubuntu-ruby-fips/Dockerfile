ARG UBUNTU_VERSION=22.04
# ARG OPENSSL_BUILDER_TAG
# ARG PG_BUILDER_TAG
# ARG BUNDLER_VERSION=2.2.33

FROM ubuntu:${UBUNTU_VERSION} as fips-provider-builder

ARG OPEN_SSL_FIPS_PROVIDER_VERSION=3.0.0

RUN apt-get update && \
	apt-get install -y curl build-essential checkinstall zlib1g-dev

RUN curl https://www.openssl.org/source/openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION}.tar.gz --output /tmp/openssl.tar.gz && \
	cd /tmp && \
	tar -xf openssl.tar.gz && \
	cd openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION} && \
	./config enable-fips --openssldir=/usr/lib/ssl --prefix=/usr/lib/ssl && \
	make -j 4 -s

ENV OPENSSL_CONF=/etc/ssl/openssl.cnf

RUN	cd /tmp/openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION} && \
	make install_fips && \
    cp /usr/lib/ssl/lib/ossl-modules/fips.so /tmp/fips.so


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
	apt-get clean

COPY --from=ubuntu-ruby-builder /usr/bin/* /usr/bin/

COPY --from=fips-provider-builder /tmp/fips.so /tmp/fips.so

COPY enable_fips.sh /tmp/enable_fips.sh
RUN /tmp/enable_fips.sh

FROM ubuntu-ruby-fips-slim as ubuntu-ruby-fips-dev

RUN apt-get update && \
	apt-get install -y postgresql-client && \
	apt-get clean

CMD ruby --version && openssl list --digest-commands -provider fips && openssl list --digest-commands && sleep infinity