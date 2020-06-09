#!/bin/bash -e

cd "$(dirname "$0")"

../push.sh --image-name ubuntu-ruby-fips --image-tag $1 --image-base-version 20.04
