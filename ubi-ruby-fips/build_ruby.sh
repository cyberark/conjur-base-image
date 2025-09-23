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

  # Uninstall unused gems to not introduce vulnerabilities in the future
  "${RUBY_HOME:=/var/lib/ruby}/bin/gem" uninstall -aI net-imap net-pop net-smtp rexml
}

# When we move to the ruby version that uses this openssl version by default then we can remove this method
# This will be when we move to Ruby 3.3 or later.
patch_openssl_gem() {
  export PATH="${RUBY_HOME:=/var/lib/ruby}/bin:${PATH}"
  OPENSSL_GEM_VERSION="3.2.0"
  OLD_OPENSSL_GEM_VERSION="3.1.0"

  # Installing the new gem without --default flag. Otherwise we would have 2 default gems and it would mess up the installation
  gem install openssl --version "$OPENSSL_GEM_VERSION"

  # Old gemspec needs to be moved up, out of the default directory. Otherwise the gem cannot be uninstalled
  mv "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/specifications/default/openssl-$OLD_OPENSSL_GEM_VERSION.gemspec" "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/specifications/"
  gem uninstall openssl --version "$OLD_OPENSSL_GEM_VERSION"

  # When uninstalling default gems old .rb and .so files are left unchanged, so we need to replace the old ones with the newly installed ones
  mv -f "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/gems/openssl-$OPENSSL_GEM_VERSION/lib/openssl.rb" "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/"
  mv -f "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/gems/openssl-$OPENSSL_GEM_VERSION/lib/openssl.so" "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/$(arch)-linux/"

  # "openssl" directory is also unchanged so we need to replace the old one by removing it and moving the newly installed one into its place
  rm -rf "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/openssl"
  mv "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/gems/openssl-$OPENSSL_GEM_VERSION/lib/openssl" "/var/lib/ruby/lib/ruby/$RUBY_MAJOR_VERSION.0/"

  # Move the new gemspec to the "default" directory. This will result in the new openssl gem being treated as a default gem
  mv "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/specifications/openssl-$OPENSSL_GEM_VERSION.gemspec" "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/specifications/default/"

  # Remove the unnecessary openssl.so file
  rm -f "/var/lib/ruby/lib/ruby/gems/$RUBY_MAJOR_VERSION.0/extensions/$(arch)-linux/$RUBY_MAJOR_VERSION.0/openssl-$OPENSSL_GEM_VERSION/openssl.so"
}

main "$@"

set +e
