#!/bin/bash -e

cd "$(dirname "$0")"

../push.sh --image-name phusion-ruby-fips --image-tag $1 --image-base-version 0.11
