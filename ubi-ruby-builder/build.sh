#!/bin/bash

cd "$(dirname "$0")"

UBI_VERSION=ubi8
RUBY_MAJOR_VERSION=2.5
RUBY_FULL_VERSION=2.5.8

docker build -t ubi-ruby-builder:"$RUBY_FULL_VERSION-fips" \
  --build-arg UBI_VERSION="$UBI_VERSION" \
  --build-arg RUBY_MAJOR_VERSION="$RUBY_MAJOR_VERSION" \
  --build-arg RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  .