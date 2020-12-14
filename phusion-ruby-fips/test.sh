#!/bin/bash -e

cd "$(dirname "$0")"

# run common tests
../test.sh --full-image-name phusion-ruby-fips:latest --test-file-name test.yml

# run phusion specific tests
../test.sh --full-image-name phusion-ruby-fips:latest --test-file-name phusion-ruby-fips/test.yml
