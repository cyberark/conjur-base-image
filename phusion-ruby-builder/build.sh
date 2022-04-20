#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
PHUSION_VERSION=0.11
RUBY_MAJOR_VERSION=3.0
RUBY_FULL_VERSION=3.0.4

docker build -t phusion-ruby-builder:"$RUBY_FULL_VERSION-fips" \
  --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
  --build-arg RUBY_MAJOR_VERSION="$RUBY_MAJOR_VERSION" \
  --build-arg RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  .
