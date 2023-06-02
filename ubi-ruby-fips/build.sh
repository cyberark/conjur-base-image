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
  .

docker build -t ubi-ruby-fips:"${UBI_VERSION}"-slim \
	--target=ubi-ruby-fips-slim \
	--pull \
  --build-arg UBI_VERSION \
  --build-arg RUBY_FULL_VERSION \
  --build-arg RUBY_MAJOR_VERSION \
	--build-arg RUBY_SHA256 \
	--build-arg BUNDLER_VERSION \
  .

set +e
