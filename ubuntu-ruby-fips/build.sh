#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

REPO_ROOT="$(git rev-parse --show-toplevel)"
PG_BUILDER_TAG=15-15.3-fips

function build() {
  set -e
  echo "building ${1} image from target ${2}"
  docker build \
    --tag "${1}" \
    --target="${2}" \
    --build-arg UBUNTU_VERSION \
    --build-arg RUBY_FULL_VERSION \
    --build-arg RUBY_MAJOR_VERSION \
    --build-arg RUBY_SHA256 \
    --build-arg BUNDLER_VERSION \
    --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
    --build-arg PG_BUILDER_TAG="$PG_BUILDER_TAG" \
    .
}

build "ubuntu-ruby-postgres-fips:latest" ubuntu-ruby-postgres-fips
build "ubuntu-ruby-fips:latest" ubuntu-ruby-fips-dev
build "ubuntu-ruby-builder:latest" ubuntu-ruby-builder
build "ubuntu-ruby-fips:slim" ubuntu-ruby-fips-slim
