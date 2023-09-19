#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

function build() {
  set -e
  echo "building ${1} image from target ${2}"
  docker buildx build \
    --tag "${1}" \
    --target="${2}" \
    --pull \
    --platform linux/arm64 \
    --build-arg UBI_VERSION \
    --build-arg RUBY_FULL_VERSION \
    --build-arg RUBY_MAJOR_VERSION \
    --build-arg RUBY_SHA256 \
    --build-arg BUNDLER_VERSION \
    --build-arg PG_VERSION \
    .
}

build "ubi-ruby-fips:latest" ubi-ruby-fips-dev
build "ubi-ruby-fips:slim" ubi-ruby-fips-slim
build "ubi-ruby-builder:latest" ubi-ruby-builder

echo "Running docker container to generate description..."
OPENSSL_VERSION=$(docker run --rm ubi-ruby-fips:latest openssl version | tail -1 | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/')
PG_VERSION=$(docker run --rm ubi-ruby-fips:latest dnf list installed libpq5 | tail -1 | tr -s ' ' | cut -d' ' -f2- | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/')
export OPENSSL_VERSION
export PG_VERSION
./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
