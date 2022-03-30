#!/bin/bash

cd "$(dirname "$0")"

REPO_ROOT="$(git rev-parse --show-toplevel)"
PG_VERSION=10-10.16

docker build -t postgres-client-builder:"$PG_VERSION-fips" \
  --build-arg PG_VERSION="$PG_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$(< "${REPO_ROOT}"/openssl-builder/OPENSSL_BUILDER_TAG)" \
  .
