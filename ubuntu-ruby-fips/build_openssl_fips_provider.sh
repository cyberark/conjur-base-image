#!/bin/bash

set -e

apt-get update
apt-get install -y \
	curl \
	build-essential \
	checkinstall \
	zlib1g-dev

curl "https://www.openssl.org/source/openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION}.tar.gz" --output /tmp/openssl.tar.gz

cd /tmp
echo "$OPEN_SSL_FIPS_PROVIDER_SHA256" openssl.tar.gz | sha256sum -c -

tar -xf openssl.tar.gz
cd "openssl-${OPEN_SSL_FIPS_PROVIDER_VERSION}"
./config enable-fips --openssldir=/usr/lib/ssl --prefix=/usr/lib/ssl
make --jobs 4 --silent

cp providers/fips.so /usr/local/lib/fips.so

set +e
