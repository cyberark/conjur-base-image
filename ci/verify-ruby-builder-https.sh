#!/bin/bash
# Verify ubuntu-ruby-builder can reach RubyGems over HTTPS with non-FIPS OpenSSL config.
# Run on AmznDocker (FIPS host) to confirm whether bundle install works in builder containers.

set -euo pipefail

cd "$(dirname "$0")/.."

ARCHITECTURE=$(./resolve_architecture.sh)
IMAGE="${BUILDER_IMAGE:-ubuntu-ruby-builder:latest-${ARCHITECTURE}}"

echo "Verifying HTTPS from ${IMAGE}..."
docker run --rm \
  "${IMAGE}" \
  sh -c 'OPENSSL_CONF=/usr/lib/ssl/openssl_non_fips.cnf \
    ruby -ropenssl -e "puts OpenSSL::OPENSSL_VERSION"; \
    curl -fsSL https://rubygems.org > /dev/null && echo HTTPS_OK'
