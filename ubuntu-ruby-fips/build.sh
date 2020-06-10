#!/bin/bash

cd "$(dirname "$0")"

UBUNTU_VERSION=20.04
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16
RUBY_BUILDER_TAG=2.5.1-fips
PG_BUILDER_TAG=12-12.2-fips
IMAGE_TAG=$1

docker build -t ubuntu-ruby-fips:"$IMAGE_TAG" \
  --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  --build-arg PG_BUILDER_TAG="$PG_BUILDER_TAG" \
  .
