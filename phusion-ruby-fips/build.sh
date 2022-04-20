#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
PHUSION_VERSION=focal-1.2.0
RUBY_BUILDER_TAG=3.0.4-fips
PG_BUILDER_TAG=10-10.16-fips
OPENLDAP_BUILDER_TAG=2.4.46-fips

docker build -t phusion-ruby-fips:latest \
  --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  --build-arg PG_BUILDER_TAG="$PG_BUILDER_TAG" \
  --build-arg OPENLDAP_BUILDER_TAG="$OPENLDAP_BUILDER_TAG" \
  .
