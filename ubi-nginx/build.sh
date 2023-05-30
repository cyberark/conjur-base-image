#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

docker build -t ubi-nginx:latest \
  --pull \
  --build-arg UBI_VERSION \
  .
