#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a
source ../versions.env
set +a

LOCAL_IMAGE="ubi-ruby-fips"
IMAGE="cyberark/ubi-ruby-fips"
REGISTRY="$(normalize_repo_name "$1")"

tag_and_push "${LOCAL_IMAGE}:${UBI_VERSION}" "${REGISTRY}${IMAGE}:${UBI_VERSION}"
tag_and_push "${LOCAL_IMAGE}:${UBI_VERSION}-slim" "${REGISTRY}${IMAGE}:${UBI_VERSION}-slim"
