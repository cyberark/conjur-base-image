#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

REGISTRY="$(normalize_repo_name "$1")"

TAG=$(<../VERSION)
IMAGE="${REGISTRY}conjur-nginx"

# Push multi-arch image only to internal registry
create_and_push_manifest \
  "${IMAGE}:${UBI_VERSION}-${TAG}-amd64" \
  "${IMAGE}:${UBI_VERSION}-${TAG}-arm64" \
  "${IMAGE}:${UBI_VERSION}-${TAG}"
create_and_push_manifest \
  "${IMAGE}:${UBI_VERSION}-amd64" \
  "${IMAGE}:${UBI_VERSION}-arm64" \
  "${IMAGE}:${UBI_VERSION}"
create_and_push_manifest \
  "${IMAGE}:${TAG}-amd64" \
  "${IMAGE}:${TAG}-arm64" \
  "${IMAGE}:${TAG}"
create_and_push_manifest \
  "${IMAGE}:latest-amd64" \
  "${IMAGE}:latest-arm64" \
  "${IMAGE}:latest"
