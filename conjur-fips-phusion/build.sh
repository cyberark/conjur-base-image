#!/bin/bash
image_tag=$1
cd "$(dirname "$0")"
docker build -t conjur-fips-phusion:"$image_tag" .
