#!/bin/bash

set -e

curl "https://www.openssl.org/source/openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION}.tar.gz" --output /tmp/openssl.tar.gz

cd /tmp
tar -xf openssl.tar.gz
cd "openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION}"
./config enable-fips --openssldir=/usr/lib/ssl --prefix=/usr/lib/ssl
make -j 4 -s

cp providers/fips.so /usr/local/lib/fips.so

set +e
