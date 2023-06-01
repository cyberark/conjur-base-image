#!/bin/bash

set -e

sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

apt-get update
apt-get install -y build-essential \
	libreadline-dev \
	gcc \
	make \
	zlib1g-dev \
	libssl-dev \
	openssl \
	ca-certificates \
	dpkg-dev \
	curl

# Compile ruby
curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_FULL_VERSION}.tar.gz" --output "ruby-${RUBY_FULL_VERSION}.tar.gz"

echo "$RUBY_SHA256 ruby-$RUBY_FULL_VERSION.tar.gz" | sha256sum -c -

tar -xvf ruby-"${RUBY_FULL_VERSION}".tar.gz
cd ruby-"${RUBY_FULL_VERSION}"

OPENSSL_DIR=$(openssl version -d | sed -n 's/.*"\(.*\)"/\1/p')
./configure --prefix=/usr/local --without-openssl --with-openssl-dir="${OPENSSL_DIR}"
make -j4
make install

set -e
