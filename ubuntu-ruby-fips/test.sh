#!/bin/bash -e

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

# run common tests
../test.sh --full-image-name "ubuntu-ruby-fips:latest" --test-file-name test-ubuntu-ruby-fips.yml
../test.sh --full-image-name "ubuntu-ruby-postgres-fips:latest" --test-file-name test-ubuntu-ruby-postgres-fips.yml
