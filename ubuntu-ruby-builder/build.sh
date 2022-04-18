#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
UBUNTU_VERSION=20.04
RUBY_MAJOR_VERSION=3.0
RUBY_FULL_VERSION=3.0.4

docker build -t ubuntu-ruby-builder:"$RUBY_FULL_VERSION-fips" \
  --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
  --build-arg RUBY_MAJOR_VERSION="$RUBY_MAJOR_VERSION" \
  --build-arg RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  .
