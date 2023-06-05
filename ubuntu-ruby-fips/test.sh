#!/bin/bash -e

cd "$(dirname "$0")"

# run common tests
../test.sh --full-image-name ubuntu-ruby-fips:22.04 --test-file-name test.yml
