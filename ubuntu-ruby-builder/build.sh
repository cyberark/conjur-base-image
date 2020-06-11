#!/bin/bash

cd "$(dirname "$0")"

UBUNTU_VERSION=20.04
RUBY_MAJOR_VERSION=2.5
RUBY_FULL_VERSION=2.5.1
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16

docker build -t ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips" \
  --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
  --build-arg RUBY_MAJOR_VERSION="$RUBY_MAJOR_VERSION" \
  --build-arg RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  .
