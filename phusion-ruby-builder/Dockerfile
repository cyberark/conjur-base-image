# Declare Phusion and Ruby versions
ARG PHUSION_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG OPENSSL_BUILDER_TAG

# OpenSSL Builder
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder

# Ruby Builder
FROM phusion/baseimage:$PHUSION_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG RUBY_SHA256=9afc6380a027a4fe1ae1a3e2eccb6b497b9c5ac0631c12ca56f9b7beb4848776

ENV LD_LIBRARY_PATH="/usr/local/ssl/lib"

COPY --from=OpenSSL-builder /usr/local/ssl/ /usr/local/ssl/

RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y build-essential \
                       libreadline-dev \
                       gcc \
                       make \
                       zlib1g-dev \
                       dpkg-dev \
                       wget

## Compile Ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --with-openssl-dir=/usr/local/ssl --disable-install-doc --disable-install-rdoc --disable-install-capi --enable-shared --prefix=/var/lib/ruby && \
    make -j4 && \
    make install
