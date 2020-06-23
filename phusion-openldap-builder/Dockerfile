ARG PHUSION_VERSION
ARG OPENSSL_BUILDER_TAG
ARG OPENLDAP_VERSION


FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder

FROM phusion/baseimage:$PHUSION_VERSION
ENV PATH="/usr/local/ssl/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/ssl/lib" \
    OPENSSL_FIPS=1

COPY --from=OpenSSL-builder /usr/local/ssl/ /usr/local/ssl/

# Install the dependencies for OpenLDAP with OpenSSL
RUN DEBIAN_FRONTEND=noninteractive  apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y devscripts wget \
    && DEBIAN_FRONTEND=noninteractive apt-get build-dep -y libldap2-dev

# OpenLDAP 2.4.46 is the earliest version to support OpenSSL 1.1.1,
# which is included with phusion/baseimage:0.11
ARG OPENLDAP_VERSION
ARG openldap_base_url=https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/openldap/${OPENLDAP_VERSION}+dfsg-5ubuntu1.2

ARG ORIGINAL_SRC_SHA256=e93cb511f6bce162c27502d0d240e6410a8f14e72c47ddddb4e69b25b7c538e4
ARG DEBIAN_SRC_SHA256=b727928852dd03fc7cc7587b2623c2e206e6bbc11447dfcb2f7f7749a068e5f3

RUN cd /root && \
    #
    # The openldap source in the debian packages for 0.11 are for 2.4.45, so we pull
    # the source for 2.4.46 using direct links:
    wget -q ${openldap_base_url}/openldap_${OPENLDAP_VERSION}+dfsg.orig.tar.gz &&\
    echo "$ORIGINAL_SRC_SHA256 openldap_${OPENLDAP_VERSION}+dfsg.orig.tar.gz" | sha256sum -c - && \
    tar -xvf openldap_${OPENLDAP_VERSION}+dfsg.orig.tar.gz && \
    #
    # Download the debian src diffs for openldap
    wget -q ${openldap_base_url}/openldap_${OPENLDAP_VERSION}+dfsg-5ubuntu1.2.debian.tar.xz && \
    echo "$DEBIAN_SRC_SHA256 openldap_${OPENLDAP_VERSION}+dfsg-5ubuntu1.2.debian.tar.xz" | sha256sum -c - && \
    cat openldap_${OPENLDAP_VERSION}+dfsg-5ubuntu1.2.debian.tar.xz | tar -xJv --directory ./openldap-* && \
    #
    # Once the debian packages include >= 2.4.46, the following line may be used to pull
    # the source for openldap instead:
    # && DEBIAN_FRONTEND=noninteractive apt-get source -y openldap \
    #
    # Build the openldap debian packages using openssl rather than gnutls
    cd openldap-* &&\
    env CC=gcc CPPFLAGS=-I/usr/local/ssl/include LDFLAGS=-L/usr/local/ssl/lib \
      ./configure --with-tls=openssl --prefix=/usr/local/openldap ; \
      make depend ; \
      make; \
      make install


