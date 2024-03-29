#!/bin/bash

set -e

apt-get update
apt-get install -y build-essential \
  libreadline-dev \
  gcc \
  make \
  zlib1g-dev \
  libssl-dev \
  libyaml-dev \
  openssl \
  ca-certificates \
  dpkg-dev \
  curl

# Compile ruby
curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_FULL_VERSION}.tar.gz" --output "ruby-${RUBY_FULL_VERSION}.tar.gz"
echo "${RUBY_SHA256}" "ruby-${RUBY_FULL_VERSION}.tar.gz" | sha256sum -c -
tar -xvf "ruby-${RUBY_FULL_VERSION}.tar.gz"
cd "ruby-${RUBY_FULL_VERSION}"

./configure --prefix="${RUBY_HOME:=/var/lib/ruby}" --enable-shared --enable-openssl --disable-install-doc
make --jobs "$(nproc --all)"
make install

"${RUBY_HOME:=/var/lib/ruby}/bin/gem" install bundler -v "${BUNDLER_VERSION}" --no-document

set -e
