# Declare Ubuntu and Ruby versions
ARG UBUNTU_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG OPENSSL_BUILDER_TAG

# OpenSSL Builder
FROM openssl-builder:$OPENSSL_BUILDER_TAG as OpenSSL-builder

# Ruby Builder
FROM ubuntu:$UBUNTU_VERSION
ARG RUBY_MAJOR_VERSION
ARG RUBY_FULL_VERSION
ARG RUBY_SHA256=5085dee0ad9f06996a8acec7ebea4a8735e6fac22f22e2d98c3f2bc3bef7e6f1

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

## Compile ruby
RUN wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --with-openssl-dir=/usr/local/ssl --prefix=/var/lib/ruby && \
    make -j4 && \
    make install
