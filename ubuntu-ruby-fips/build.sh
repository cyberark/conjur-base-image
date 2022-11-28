#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
UBUNTU_VERSION=20.04
RUBY_BUILDER_TAG=3.0.5-fips
PG_BUILDER_TAG=10-10.16-fips

docker build -t ubuntu-ruby-fips:latest \
  --build-arg UBUNTU_VERSION="$UBUNTU_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  --build-arg PG_BUILDER_TAG="$PG_BUILDER_TAG" \
  .
