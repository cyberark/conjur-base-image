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
	--build-arg OPEN_SSL_FIPS_PROVIDER_SHA256 \
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
	--build-arg OPEN_SSL_FIPS_PROVIDER_SHA256 \
	.

echo "Running docker container to generate description..."
docker run --rm \
  --env BUNDLER_VERSION="$BUNDLER_VERSION" \
  --env RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  --env PG_VERSION="$PG_VERSION" \
  --volume "$(pwd):/docs" \
  --workdir "/docs" \
  ubuntu-ruby-fips:"${UBUNTU_VERSION}" \
  ./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
