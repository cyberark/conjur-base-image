#!/bin/bash

cd "$(dirname "$0")"

OPENSSL_VER=1.0.2u
OPENSSL_FIPS_VER=2.0.16

docker pull registry.tld/openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER"

if [ $? -ne 0 ] || "$1"; then
  docker tag openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER" registry.tld/openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER"
  docker push registry.tld/openssl-builder:"$OPENSSL_VER-fips-$OPENSSL_FIPS_VER"
fi
