#!/bin/bash

set -e

cd "$(dirname "$0")"

#REPO_ROOT="$(git rev-parse --show-toplevel)"

set -a
source ../versions.env
set +a

docker build -t ubuntu-ruby-fips:"${UBUNTU_VERSION}" \
	--target=ubuntu-ruby-fips-dev \
	--pull \
	--build-arg UBUNTU_VERSION \
	--build-arg RUBY_FULL_VERSION \
	--build-arg RUBY_MAJOR_VERSION \
	--build-arg RUBY_SHA256 \
	--build-arg BUNDLER_VERSION \
	--build-arg PG_VERSION \
	--build-arg OPEN_SSL_FIPS_PROVIDER_VERSION \
	.

docker build -t ubuntu-ruby-fips:"${UBUNTU_VERSION}"-slim \
	--target=ubuntu-ruby-fips-slim \
	--pull \
	--build-arg UBUNTU_VERSION \
	--build-arg RUBY_FULL_VERSION \
	--build-arg RUBY_MAJOR_VERSION \
	--build-arg RUBY_SHA256 \
	--build-arg BUNDLER_VERSION \
	--build-arg PG_VERSION \
	--build-arg OPEN_SSL_FIPS_PROVIDER_VERSION \
	.

set +e
