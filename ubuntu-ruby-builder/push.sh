#!/bin/bash

cd "$(dirname "$0")"

RUBY_FULL_VERSION=2.5.1

docker pull registry.tld/ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips"

if [ $? -ne 0 ] || "$1"; then
  docker tag ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips" registry.tld/ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips"
  docker push registry.tld/ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips"
fi
