#!/bin/bash

cd "$(dirname "$0")"

OPENSSL_VER=1.0.2u
OPENSSL_FIPS_VER=2.0.16

docker pull registry.tld/openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER"

if [ $? -ne 0 ] || "$1"; then
  docker build -t openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER" \
    --build-arg OPENSSL_VER="$OPENSSL_VER" \
    --build-arg OPENSSL_FIPS_VER="$OPENSSL_FIPS_VER" \
    .
fi
