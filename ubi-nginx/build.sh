#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

docker buildx build -t ubi-nginx:latest \
  --pull \
  --platform linux/arm64 \
  --build-arg UBI_VERSION \
  .
