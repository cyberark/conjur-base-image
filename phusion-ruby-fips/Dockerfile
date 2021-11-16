ARG PHUSION_VERSION
ARG OPENSSL_BUILDER_TAG
ARG RUBY_BUILDER_TAG
ARG PG_BUILDER_TAG
ARG OPENLDAP_BUILDER_TAG
ARG BUNDLER_VERSION=2.2.30

# OpenSSL, ruby and postgres-client Builders
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder
FROM phusion-ruby-builder:$RUBY_BUILDER_TAG as phusion-ruby-builder
FROM postgres-client-builder:$PG_BUILDER_TAG as postgres-client-builder
FROM phusion-openldap-builder:$OPENLDAP_BUILDER_TAG as openldap-builder

# Conjur Base Image (Phusion)
FROM phusion/baseimage:$PHUSION_VERSION
ARG BUNDLER_VERSION

### We need libreadline-dev for its readline capabilities
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y libreadline-dev

RUN apt-get purge -y --auto-remove openssl libssl1.1 libldap-2.4-2
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
COPY --from=phusion-ruby-builder /var/lib/ruby/ /var/lib/ruby/
COPY --from=openldap-builder /usr/local/openldap/ /usr/local/openldap/

ENV PATH="/usr/local/openldap/bin:/usr/local/pgsql/bin:/var/lib/ruby/bin:/usr/local/ssl/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/ssl/lib" \
    OPENSSL_FIPS=1

## Install Ruby tools
RUN gem install --no-document bundler:$BUNDLER_VERSION
