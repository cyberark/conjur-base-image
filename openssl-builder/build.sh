#!/bin/bash

set -euxo pipefail

cd "$(dirname "$0")"

OPENSSL_VER="1.0.2zf-53"

if ! git clone git@github.com:conjurinc/openssl.git; then
  echo "Could not clone conjurinc/openssl repo"
  exit 1
fi

if [ ! -d "openssl/openssl${OPENSSL_VER}" ]; then
  echo "Could not find OpenSSL source directory openssl/openssl-${OPENSSL_VER}"
  exit 1
fi


OPENSSL_BUILDER_TAG="${OPENSSL_VER}"
echo "${OPENSSL_BUILDER_TAG}" > OPENSSL_BUILDER_TAG

docker build -t openssl-builder:"${OPENSSL_BUILDER_TAG}" \
  --build-arg OPENSSL_VER="${OPENSSL_VER}" \
  .
