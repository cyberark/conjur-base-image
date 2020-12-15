#!/bin/bash -e

cd "$(dirname "$0")"

# run common tests
../test.sh --full-image-name ubi-ruby-fips:latest --test-file-name test-ubi.yml
