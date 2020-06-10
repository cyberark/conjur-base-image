#!/bin/bash

cd "$(dirname "$0")"

PHUSION_VERSION=0.11
RUBY_MAJOR_VERSION=2.5
RUBY_FULL_VERSION=2.5.1
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16

docker pull registry.tld/phusion-ruby-builder:"$RUBY_FULL_VERSION-fips"

if [ $? -ne 0 ] || "$1"; then
  docker build -t phusion-ruby-builder:"$RUBY_FULL_VERSION-fips" \
    --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
    --build-arg RUBY_MAJOR_VERSION="$RUBY_MAJOR_VERSION" \
    --build-arg RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
    --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
    .
fi
