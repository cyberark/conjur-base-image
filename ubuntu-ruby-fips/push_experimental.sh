#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a
source ../versions.env
set +a

REGISTRY="$(normalize_repo_name "$1")"

IMAGES=(
  "ubuntu-ruby-postgres-fips:latest"
  "ubuntu-ruby-fips:latest"
  "ubuntu-ruby-builder:latest"
  "ubuntu-ruby-fips:slim"
)

for image in "${IMAGES[@]}"; do
  LOCAL_IMAGE="${image}"
  IMAGE="cyberark/${image}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE%:*}:22.04"
done