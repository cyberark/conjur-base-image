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
function push_image() {
  TAG=$(<../VERSION)
  IMAGE="cyberark/${1}"

  if [[ -n "${REGISTRY:-}" ]]; then
    IMAGE="${REGISTRY}${IMAGE}"
  fi

  # Push to internal locations
  create_and_push_manifest \
    "${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}-amd64" \
    "${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}-arm64" \
    "${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}"
  create_and_push_manifest \
    "${IMAGE}:${UBUNTU_VERSION}${3}-amd64" \
    "${IMAGE}:${UBUNTU_VERSION}${3}-arm64" \
    "${IMAGE}:${UBUNTU_VERSION}${3}"
  create_and_push_manifest \
    "${IMAGE}:${TAG}${3}-amd64" \
    "${IMAGE}:${TAG}${3}-arm64" \
    "${IMAGE}:${TAG}${3}"
  create_and_push_manifest \
    "${IMAGE}:${2}-amd64" \
    "${IMAGE}:${2}-arm64" \
    "${IMAGE}:${2}"
}

push_image "ubuntu-ruby-builder" "latest" ""
push_image "ubuntu-ruby-fips" "latest" ""
push_image "ubuntu-ruby-postgres-fips" "latest" ""
push_image "ubuntu-ruby-fips" "slim" "-slim"