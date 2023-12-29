#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

ARCHITECTURE=$(../resolve_architecture.sh)

LOCAL_IMAGE="ubi-nginx:latest-${ARCHITECTURE}"
IMAGE="registry.tld/conjur-nginx"
TAG=$(<../VERSION)
HASH=$(git log -1 --pretty=format:%h)

tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${TAG}-${HASH}-${ARCHITECTURE}"
