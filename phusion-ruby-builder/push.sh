#!/bin/bash

cd "$(dirname "$0")"

RUBY_FULL_VERSION=2.5.1

docker pull registry.tld/phusion-ruby-builder:"$RUBY_FULL_VERSION-fips"

if [ $? -ne 0 ] || "$1"; then
  docker tag phusion-ruby-builder:"$RUBY_FULL_VERSION-fips" registry.tld/phusion-ruby-builder:"$RUBY_FULL_VERSION-fips"
  docker push registry.tld/phusion-ruby-builder:"$RUBY_FULL_VERSION-fips"
fi
