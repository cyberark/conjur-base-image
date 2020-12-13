#!/bin/bash

cd "$(dirname "$0")"

PG_VERSION=10-10.15
OPENSSL_BUILDER_TAG=1.0.2u-fips-2.0.16

DOCKER_USER=$1

docker buildx build -t $DOCKER_USER/postgres-client-builder:"$PG_VERSION-fips" \
  --build-arg PG_VERSION="$PG_VERSION" \
  --build-arg OPENSSL_BUILDER_TAG="$OPENSSL_BUILDER_TAG" \
  --build-arg DOCKER_USER="$DOCKER_USER" \
  --platform linux/amd64,linux/arm64 . --push
