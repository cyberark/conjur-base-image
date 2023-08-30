#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

# Needs to be kept as close as possible to appliance's NGINX version.
NGINX_VERSION=1.20

docker build -t ubi-nginx:latest \
  --pull \
  --build-arg UBI_VERSION \
  --build-arg NGINX_VERSION="${NGINX_VERSION}" \
  .
