#!/bin/bash -e

cd "$(dirname "$0")"

# run common tests
../test.sh --full-image-name ubi-ruby-fips:ubi9 --test-file-name test-ubi.yml
