#!/bin/bash

cd "$(dirname "$0")"

UBI_VERSION=ubi9
RUBY_BUILDER_TAG=3.0.6-fips

docker build -t ubi-ruby-fips:ubi9 \
	--target=ubi-ruby-fips-dev \
  --build-arg UBI_VERSION="$UBI_VERSION" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  .

docker build -t ubi-ruby-fips:ubi9-slim \
	--target=ubi-ruby-fips-slim \
  --build-arg UBI_VERSION="$UBI_VERSION" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  .
