#!/bin/bash

set -e

yum -y clean all && yum -y makecache && yum -y update

yum install -y --setopt=tsflags=nodocs gcc \
                                       gcc-c++ \
                                       make \
                                       openssl-devel \
                                       wget \
                                       zlib-devel \
                                       readline

## Compile ruby
wget --quiet https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR_VERSION/ruby-$RUBY_FULL_VERSION.tar.gz && \
    echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c - && \
    tar -xvf ruby-$RUBY_FULL_VERSION.tar.gz && \
    cd ruby-$RUBY_FULL_VERSION && \
    ./configure --prefix=/var/lib/ruby --without-openssl --with-openssl-dir=/etc/pki/tls && \
    make -j4 && \
    make install && \
    wget https://rubygems.org/downloads/openssl-3.0.0.gem && \
    /var/lib/ruby/bin/gem install openssl-3.0.0.gem

set -e