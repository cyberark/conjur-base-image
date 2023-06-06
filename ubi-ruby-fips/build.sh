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

echo "Running docker container to generate description..."
docker run --rm \
  --env BUNDLER_VERSION="$BUNDLER_VERSION" \
  --env RUBY_FULL_VERSION="$RUBY_FULL_VERSION" \
  --env PG_VERSION="$PG_VERSION" \
  --volume "$(pwd):/docs" \
  --workdir "/docs" \
  ubi-ruby-fips:"${UBI_VERSION}"-slim \
  ./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
