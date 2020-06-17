ARG UBUNTU_VERSION
ARG OPENSSL_BUILDER_TAG
ARG RUBY_BUILDER_TAG
ARG PG_BUILDER_TAG
ARG BUNDLER_VERSION=2.1.4

# OpenSSL, ruby and postgres-client Builders
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder
FROM ubuntu-ruby-builder:$RUBY_BUILDER_TAG as ubuntu-ruby-builder
FROM postgres-client-builder:$PG_BUILDER_TAG as postgres-client-builder

# Conjur Base Image (Ubuntu)
FROM ubuntu:$UBUNTU_VERSION
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
COPY --from=openSSL-builder /ca-certificates_20190110ubuntu1.1_all.deb /
COPY --from=openSSL-builder /openssl_1.0.2u_all.deb /
COPY --from=openSSL-builder /libssl1.0.0_1.0.2u_all.deb /

RUN dpkg -i ca-certificates_20190110ubuntu1.1_all.deb
RUN dpkg -i openssl_1.0.2u_all.deb
RUN dpkg -i libssl1.0.0_1.0.2u_all.deb

## Prevent openssl and libssl package from being automatically installed, upgraded or remove
RUN apt-mark hold ca-certificates
RUN apt-mark hold openssl
RUN apt-mark hold libssl1.0.0
RUN apt-mark hold libssl1.1

## Copy postgres and ruby binaries from fips-artifacts
RUN mkdir -p /var/lib/pgsql/ /var/lib/ruby/
COPY --from=postgres-client-builder /usr/local/pgsql/ /usr/local/pgsql/
COPY --from=ubuntu-ruby-builder /var/lib/ruby/ /var/lib/ruby/

ENV PATH="/usr/local/pgsql/bin:/var/lib/ruby/bin:/usr/local/ssl/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/ssl/lib" \
    OPENSSL_FIPS=1

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION
