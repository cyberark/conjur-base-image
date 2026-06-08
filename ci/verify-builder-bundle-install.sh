#!/bin/bash
# Mirror Conjur builder-stage behavior: bundle install inside ubuntu-ruby-builder on a FIPS host.
# Uses the repo Gemfile/Gemfile.lock (same gems pre-installed into base images during build_ruby.sh).

set -euo pipefail

cd "$(dirname "$0")/.."

ARCHITECTURE=$(./resolve_architecture.sh)
IMAGE="${BUILDER_IMAGE:-ubuntu-ruby-builder:latest-${ARCHITECTURE}}"

echo "Running bundle install in ${IMAGE}..."
docker run --rm \
  -v "$(pwd)/Gemfile:/work/Gemfile:ro" \
  -v "$(pwd)/Gemfile.lock:/work/Gemfile.lock:ro" \
  -w /work \
  -e OPENSSL_CONF=/usr/lib/ssl/openssl_non_fips.cnf \
  "${IMAGE}" \
  sh -c 'bundle install && echo BUNDLE_INSTALL_OK'
