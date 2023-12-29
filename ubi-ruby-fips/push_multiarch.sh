#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

REGISTRY="$(normalize_repo_name "$1")"

# ${1} - image name
# ${2} - image tag
# ${3} - tag suffix
push_image() {
  TAG=$(<../VERSION)
  IMAGE="cyberark/${1}"

  if [[ -n "${REGISTRY:-}" ]]; then
    IMAGE="${REGISTRY}${IMAGE}"
  fi

  # Push to either internal or public registry depending on whether registry parameter was passed
  create_and_push_manifest \
    "${IMAGE}:${UBI_VERSION}-${TAG}${3}-amd64" \
    "${IMAGE}:${UBI_VERSION}-${TAG}${3}-arm64" \
    "${IMAGE}:${UBI_VERSION}-${TAG}${3}"
  create_and_push_manifest \
    "${IMAGE}:${UBI_VERSION}${3}-amd64" \
    "${IMAGE}:${UBI_VERSION}${3}-arm64" \
    "${IMAGE}:${UBI_VERSION}${3}"
  create_and_push_manifest \
    "${IMAGE}:${TAG}${3}-amd64" \
    "${IMAGE}:${TAG}${3}-arm64" \
    "${IMAGE}:${TAG}${3}"
  create_and_push_manifest \
    "${IMAGE}:${2}-amd64" \
    "${IMAGE}:${2}-arm64" \
    "${IMAGE}:${2}"
}

push_image "ubi-ruby-builder" "latest" ""
push_image "ubi-ruby-fips" "latest" ""
push_image "ubi-ruby-fips" "slim" "-slim"
