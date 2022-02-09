#!/bin/bash

cd "$(dirname "$0")"

PHUSION_VERSION=0.11
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16
RUBY_BUILDER_TAG=3.0.2-fips
PG_BUILDER_TAG=10-10.16-fips
OPENLDAP_BUILDER_TAG=2.4.46-fips

docker build -t phusion-ruby-fips:latest \
  --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  --build-arg RUBY_BUILDER_TAG="$RUBY_BUILDER_TAG" \
  --build-arg PG_BUILDER_TAG="$PG_BUILDER_TAG" \
  --build-arg OPENLDAP_BUILDER_TAG="$OPENLDAP_BUILDER_TAG" \
  .
