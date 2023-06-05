#!/bin/bash

set -e

yum -y clean all && yum -y makecache && yum -y update

yum install -y --setopt=tsflags=nodocs gcc \
	gcc-c++ \
	make \
	openssl-devel \
	zlib-devel \
	libyaml-devel \
	readline

## Compile ruby
curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_FULL_VERSION}.tar.gz" --output "ruby-${RUBY_FULL_VERSION}.tar.gz"
echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c -
tar -xvf "ruby-$RUBY_FULL_VERSION.tar.gz"
cd "ruby-$RUBY_FULL_VERSION"

./configure --prefix=/var/lib/ruby --enable-shared --disable-install-docs

make -j4
make install

set -e
