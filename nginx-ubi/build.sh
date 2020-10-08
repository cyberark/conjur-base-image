#!/bin/bash

cd "$(dirname "$0")"

NGINX_VERSION=1.14

docker build -t nginx-ubi:"$NGINX_VERSION" \
  --build-arg NGINX_VERSION="$NGINX_VERSION" .