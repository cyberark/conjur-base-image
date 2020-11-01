#!/bin/bash

cd "$(dirname "$0")"

UBI_VERSION=ubi8
RUBY_BUILDER_TAG=2.5.8-fips
IMAGE_TAG=$1

docker build -t ubi-ruby-fips:"$IMAGE_TAG" \
  --build-arg UBI_VERSION="$UBI_VERSION" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  .