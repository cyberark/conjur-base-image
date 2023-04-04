#!/bin/bash

cd "$(dirname "$0")"

UBI_VERSION=ubi8
RUBY_BUILDER_TAG=3.0.6-fips

docker build -t ubi-ruby-fips:latest \
  --build-arg UBI_VERSION="$UBI_VERSION" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  .
