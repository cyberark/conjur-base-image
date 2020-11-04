#!/bin/bash

cd "$(dirname "$0")"

# Needs to be kept as close as possible to appliance's NGINX version.
NGINX_VERSION=1.14
IMAGE_TAG=$1

docker build -t ubi-nginx:"${IMAGE_TAG}" \
  --build-arg NGINX_VERSION="${NGINX_VERSION}" .
