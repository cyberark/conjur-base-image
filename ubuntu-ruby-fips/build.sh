#!/bin/bash

set -e

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
UBUNTU_VERSION=22.04
RUBY_FULL_VERSION=3.0.6
RUBY_MAJOR_VERSION=3.0
PG_VERSION=10-10.16

docker build -t ubuntu-ruby-fips:latest \
  --build-arg UBUNTU_VERSION="${UBUNTU_VERSION}" \
  --build-arg RUBY_FULL_VERSION="${RUBY_FULL_VERSION}" \
  --build-arg RUBY_MAJOR_VERSION="${RUBY_MAJOR_VERSION}" \
  --build-arg PG_VERSION="${PG_VERSION}" \
  .

set +e