#!/bin/bash

cd "$(dirname "$0")"

OPENSSL_VER=1.0.2u
OPENSSL_FIPS_VER=2.0.16
DOCKER_USER=$1


docker buildx build -t $DOCKER_USER/openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER" \
  --build-arg OPENSSL_VER="$OPENSSL_VER" \
  --build-arg OPENSSL_FIPS_VER="$OPENSSL_FIPS_VER" \
  --platform linux/amd64,linux/arm64 . --push 
  
