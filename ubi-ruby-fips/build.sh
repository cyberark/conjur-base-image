#!/bin/bash

set -e

cd "$(dirname "$0")"

set -a
source ../versions.env
set +a

docker build -t ubi-ruby-fips:"${UBI_VERSION}" \
	--target=ubi-ruby-fips-dev \
	--pull \
	--build-arg UBI_VERSION \
	--build-arg RUBY_FULL_VERSION \
	--build-arg RUBY_MAJOR_VERSION \
	--build-arg RUBY_SHA256 \
	--build-arg BUNDLER_VERSION \
	--build-arg PG_VERSION \
	.

docker build -t ubi-ruby-fips:"${UBI_VERSION}"-slim \
	--target=ubi-ruby-fips-slim \
	--pull \
	--build-arg UBI_VERSION \
	--build-arg RUBY_FULL_VERSION \
	--build-arg RUBY_MAJOR_VERSION \
	--build-arg RUBY_SHA256 \
	--build-arg BUNDLER_VERSION \
	--build-arg PG_VERSION \
	.

echo "Running docker container to generate description..."
OPENSSL_VERSION=$(docker run --rm ubi-ruby-fips:"${UBI_VERSION}" openssl version | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/')
export OPENSSL_VERSION
./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
