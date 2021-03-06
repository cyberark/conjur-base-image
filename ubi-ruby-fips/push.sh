#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

UBI_VERSION=ubi8
LOCAL_IMAGE="ubi-ruby-fips:latest"
IMAGE="cyberark/ubi-ruby-fips"

if [[ -z "${TAG_NAME:-}" ]]; then
  # This script is NOT being run as part of a tag-triggered build
  # It will publish only to the internal registry on this run
  TAG="$(git rev-parse --short HEAD | tr -d '\n')"
  REGISTRY="$(normalize_repo_name $1)"

  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBI_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBI_VERSION}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${TAG}"
else
  # The script is being run as part of a tag-triggered build
  # It will only publish to DockerHub on this run
  TAG="${TAG_NAME//"v"}"

  main_tag_and_push "${LOCAL_IMAGE}" "${IMAGE}" "${TAG}"
fi
