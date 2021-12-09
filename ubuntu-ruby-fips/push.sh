#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

UBUNTU_VERSION=20.04
LOCAL_IMAGE="ubuntu-ruby-fips:latest"
IMAGE="cyberark/ubuntu-ruby-fips"
REGISTRY="$(normalize_repo_name "$1")"
TAG=$(<VERSION)

if [[ -z "${REGISTRY:-}" ]]; then
  # Push to public registry with VERSION
  main_tag_and_push "${LOCAL_IMAGE}" "${IMAGE}" "${TAG}"
else
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${TAG}"
fi
