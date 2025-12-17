#!/bin/bash

set -e

main() {
  build_ruby
}

build_ruby() {
  dnf -y clean all && dnf -y makecache && dnf -y update

  dnf install -y --nodocs gcc \
    gcc-c++ \
    make \
    openssl-devel \
    zlib-devel \
    libyaml-devel \
    readline \
    git

  # Compile ruby
  curl "https://cache.ruby-lang.org/pub/ruby/${RUBY_MAJOR_VERSION}/ruby-${RUBY_FULL_VERSION}.tar.gz" --output "ruby-${RUBY_FULL_VERSION}.tar.gz"
  echo "${RUBY_SHA256}" "ruby-${RUBY_FULL_VERSION}.tar.gz" | sha256sum -c -
  tar -xvf "ruby-${RUBY_FULL_VERSION}.tar.gz"
  cd "ruby-${RUBY_FULL_VERSION}"

  ./configure --prefix="${RUBY_HOME:=/var/lib/ruby}" --enable-shared --enable-openssl --disable-install-doc
  make --jobs "$(nproc --all)"
  make install

  export PATH="${RUBY_HOME:=/var/lib/ruby}/bin:${PATH}"
  gem install bundler -v "${BUNDLER_VERSION}" --no-document

  # Configure Bundler to use a shared path
  BUNDLE_PATH=/usr/local/bundle
  BUNDLE_BIN=/usr/local/bundle/bin
  export PATH="${BUNDLE_BIN}:${PATH}"

  # Install gems in a shared vendor directory
  "${RUBY_HOME:=/var/lib/ruby}/bin/bundle" config set --local path "$BUNDLE_PATH"
  "${RUBY_HOME:=/var/lib/ruby}/bin/bundle" install

  # Uninstall unused gems to not introduce vulnerabilities in the future
  "${RUBY_HOME:=/var/lib/ruby}/bin/gem" uninstall -aI net-imap net-pop net-smtp rexml
}

main "$@"

set +e
