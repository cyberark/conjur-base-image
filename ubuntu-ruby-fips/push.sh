#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

REGISTRY="$(normalize_repo_name "$1")"
ARCHITECTURE=$(../resolve_architecture.sh)

# ${1} - image name
# ${2} - image tag
# ${3} - tag suffix
push_image() {
  LOCAL_IMAGE="${1}:${2}-${ARCHITECTURE}"
  IMAGE="cyberark/${1}"
  TAG=$(<../VERSION)

  if [[ -n "${REGISTRY:-}" ]]; then
    IMAGE="${REGISTRY}${IMAGE}"
  fi

  # Push to either internal or public registry depending if registry parameter was passed
  tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${UBUNTU_VERSION}-${TAG}${3}-${ARCHITECTURE}"
  tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${UBUNTU_VERSION}${3}-${ARCHITECTURE}"
  tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${TAG}${3}-${ARCHITECTURE}"
  tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${2}-${ARCHITECTURE}"
}

push_image "ubuntu-ruby-builder" "latest" ""
push_image "ubuntu-ruby-fips" "latest" ""
push_image "ubuntu-ruby-postgres-fips" "latest" ""
push_image "ubuntu-ruby-fips" "slim" "-slim"