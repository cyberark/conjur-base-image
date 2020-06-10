#!/bin/bash

cd "$(dirname "$0")"

PG_VERSION=12-12.2
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16

docker build -t postgres-client-builder:"$PG_VERSION-fips" \
  --build-arg PG_VERSION="$PG_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  .
