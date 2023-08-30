#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

function build() {
  set -e
  echo "building ${1} image from target ${2}"
  docker build \
    --tag "${1}" \
    --target="${2}" \
    --pull \
    --build-arg UBI_VERSION \
    --build-arg RUBY_FULL_VERSION \
    --build-arg RUBY_MAJOR_VERSION \
    --build-arg RUBY_SHA256 \
    --build-arg BUNDLER_VERSION \
    .
}

build "ubi-ruby-fips:latest" ubi-ruby-fips-dev
build "ubi-ruby-fips:slim" ubi-ruby-fips-slim
build "ubi-ruby-builder:latest" ubi-ruby-builder

set +e
