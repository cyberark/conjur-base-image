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
    --build-arg UBUNTU_VERSION \
    --build-arg RUBY_FULL_VERSION \
    --build-arg RUBY_MAJOR_VERSION \
    --build-arg RUBY_SHA256 \
    --build-arg BUNDLER_VERSION \
    --build-arg PG_VERSION \
    --build-arg OPEN_SSL_FIPS_PROVIDER_VERSION \
    --build-arg OPEN_SSL_FIPS_PROVIDER_SHA256 \
    .
}

build "ubuntu-ruby-postgres-fips:latest" ubuntu-ruby-postgres-fips
build "ubuntu-ruby-fips:latest" ubuntu-ruby-fips-dev
build "ubuntu-ruby-builder:latest" ubuntu-ruby-builder
build "ubuntu-ruby-fips:slim" ubuntu-ruby-fips-slim

echo "Running docker container to generate description..."
OPENSSL_VERSION=$(docker run --rm ubuntu-ruby-fips:latest openssl version | tail -1 | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/')
PG_VERSION=$(docker run --rm ubuntu-ruby-fips:latest apt-cache show libpq5 | grep Version | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\)-.*$/\1/')
export OPENSSL_VERSION
export PG_VERSION
./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
