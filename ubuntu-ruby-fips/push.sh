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
  LOCAL_IMAGE="${1}:${2}"
  IMAGE="cyberark/${1}"
  TAG=$(<../VERSION)

  if [[ -z "${REGISTRY:-}" ]]; then
    # Push to public registry with Ubuntu version and and image versions
    tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${UBUNTU_VERSION}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${TAG}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${2}"
  else
    # Push to internal locations with Ubunntu version and image versions
    tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${TAG}${3}"
    tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${2}"
  fi
}

push_image "ubuntu-ruby-builder" "latest" ""
push_image "ubuntu-ruby-fips" "latest" ""
push_image "ubuntu-ruby-postgres-fips" "latest" ""
push_image "ubuntu-ruby-fips" "slim" "-slim"
