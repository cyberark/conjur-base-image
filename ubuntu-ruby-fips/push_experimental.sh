#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

UBUNTU_VERSION=22.04
LOCAL_IMAGE="ubuntu-ruby-fips"
IMAGE="cyberark/ubuntu-ruby-fips"
REGISTRY="$(normalize_repo_name "$1")"

tag_and_push "${LOCAL_IMAGE}:${UBUNTU_VERSION}" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}"
tag_and_push "${LOCAL_IMAGE}:${UBUNTU_VERSION}-slim" "${REGISTRY}${IMAGE}:${UBUNTU_VERSION}-slim"
