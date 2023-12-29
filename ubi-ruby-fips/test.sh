#!/bin/bash -e

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

ARCHITECTURE=$(../resolve_architecture.sh)

# run common tests
../test.sh --full-image-name "ubi-ruby-fips:latest-${ARCHITECTURE}" --test-file-name test-ubi-ruby-fips.yml
