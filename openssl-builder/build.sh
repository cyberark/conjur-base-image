#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

OPENSSL_NONFREE_VER='1.0.2ze'
OPENSSL_OSS_VER='1.0.2u'
OPENSSL_OSS_HASH='ecd0c6ffb493dd06707d38b14bb4d8c2288bb7033735606569d8f90f89669d16'
OPENSSL_VER="${OPENSSL_VER:-${OPENSSL_NONFREE_VER}}"
OPENSSL_FIPS_VER='2.0.16'

if ! git clone git@github.com:conjurinc/openssl.git; then
  if mkdir openssl; then
    pushd openssl
      wget --quiet "https://www.openssl.org/source/openssl-${OPENSSL_OSS_VER}.tar.gz"
      echo "${OPENSSL_OSS_HASH} openssl-${OPENSSL_OSS_VER}.tar.gz" | sha256sum -c - | grep OK

      tar -xzf "openssl-${OPENSSL_OSS_VER}.tar.gz"
    popd

    OPENSSL_VER="${OPENSSL_OSS_VER}"
  elif [ ! -d "openssl/openssl-${OPENSSL_VER}" ]; then
    echo "Could not find OpenSSL source directory openssl/openssl-${OPENSSL_VER}"
    exit 1
  fi
fi

OPENSSL_BUILDER_TAG="${OPENSSL_VER}-fips-${OPENSSL_FIPS_VER}"
echo "${OPENSSL_BUILDER_TAG}" > OPENSSL_BUILDER_TAG

docker build -t openssl-builder:"${OPENSSL_BUILDER_TAG}" \
  --build-arg OPENSSL_VER="${OPENSSL_VER}" \
  --build-arg OPENSSL_FIPS_VER="${OPENSSL_FIPS_VER}" \
  .
