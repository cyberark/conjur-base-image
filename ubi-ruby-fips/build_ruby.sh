#!/bin/bash

set -e

main() {
  build_ruby
  patch_openssl_gem
}

build_ruby() {
  dnf -y clean all && dnf -y makecache && dnf -y update

  dnf install -y --nodocs gcc \
    gcc-c++ \
    make \
    openssl-devel \
    zlib-devel \
    libyaml-devel \
    readline

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
}

# before actual release of the new openssl gem we need to use the specific version that
# works with UBI9 FIPS mode when RedHat patches to OpenSSL lib are enabled
#
# this should be removed after new release of ruby openssl gem is available:
# https://github.com/ruby/openssl/issues/651
patch_openssl_gem() {
  export PATH="${RUBY_HOME:=/var/lib/ruby}/bin:${PATH}"

  dnf install -y --nodocs git
  cd /tmp
  git clone https://github.com/ruby/openssl.git
  cd openssl
  git reset --hard fcda6cf9d5f69f6dc0c297ca76feff71f9021f00
  # ruby openssl gem is a special gem, deeply integrated into ruby, non of the standard installation methods allows
  # to easily update it or replace, keeping two versions in parallel may lead to unintended behaviour
  bundle install
  # we need to build the .gem file
  rake build
  # and compile the c bindings to the shared library openssl.so
  rake compile

  # default openssl is a default gem and additionally installed in a sub-standard place (not in the gems folder)
  # non of the installers/uninstallers handles that way of installation well, therefore we need to manually
  # overwrite the openssl gem ruby code together with the compiled c bindings
  cp --update "tmp/x86_64-linux/openssl/$RUBY_FULL_VERSION/openssl.so" "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/x86_64-linux/openssl.so"
  cp --update lib/openssl/* "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/openssl/"
  cp --update lib/openssl.rb "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/openssl.rb"
}

main "$@"

set +e
