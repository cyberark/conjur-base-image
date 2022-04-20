#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
PHUSION_VERSION=focal-1.2.0
OPENLDAP_VERSION=2.4.46

docker build -t phusion-openldap-builder:"$OPENLDAP_VERSION-fips" \
  --build-arg PHUSION_VERSION="$PHUSION_VERSION" \
  --build-arg OPENLDAP_VERSION="$OPENLDAP_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  .
