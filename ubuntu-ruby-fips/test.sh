#!/bin/bash -e

cd "$(dirname "$0")"

# run common tests
../test.sh --full-image-name ubuntu-ruby-fips:latest --test-file-name test.yml
