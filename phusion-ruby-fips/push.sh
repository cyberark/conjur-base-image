#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

PHUSION_VERSION=focal-1.2.0
LOCAL_IMAGE="phusion-ruby-fips:latest"
IMAGE="cyberark/phusion-ruby-fips"
REGISTRY="$(normalize_repo_name "$1")"
TAG=$(<../VERSION)

if [[ -z "${REGISTRY:-}" ]]; then
  # Push to public registry with VERSION
  main_tag_and_push "${LOCAL_IMAGE}" "${IMAGE}" "${TAG}"
else
  # Push to internal locations with VERSION and image versions
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${PHUSION_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${PHUSION_VERSION}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${TAG}"
fi
