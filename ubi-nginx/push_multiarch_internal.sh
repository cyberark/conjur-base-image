#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

IMAGE="registry.tld/conjur-nginx"
TAG=$(<../VERSION)
HASH=$(git log -1 --pretty=format:%h)

create_and_push_manifest \
  "${IMAGE}:${TAG}-${HASH}-amd64" \
  "${IMAGE}:${TAG}-${HASH}-arm64" \
  "${IMAGE}:${TAG}-${HASH}"
