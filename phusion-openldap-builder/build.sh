#!/bin/bash

cd "$(dirname "$0")"

PHUSION_VERSION=0.11
OPENLDAP_VERSION=2.4.46
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16

docker build -t phusion-openldap-builder:"$OPENLDAP_VERSION-fips" \
  --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
  --build-arg OPENLDAP_VERSION="$OPENLDAP_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  .
