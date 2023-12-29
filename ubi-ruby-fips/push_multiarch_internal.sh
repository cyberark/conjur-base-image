#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

# ${1} - image name
# ${2} - tag suffix
push_image() {
  IMAGE="registry.tld/cyberark/${1}"
  TAG=$(<../VERSION)
  HASH=$(git log -1 --pretty=format:%h)

   create_and_push_manifest \
     "${IMAGE}:${TAG}-${HASH}${2}-amd64" \
     "${IMAGE}:${TAG}-${HASH}${2}-arm64" \
     "${IMAGE}:${TAG}-${HASH}${2}"
}

push_image "ubi-ruby-builder" ""
push_image "ubi-ruby-fips" ""
push_image "ubi-ruby-fips" "-slim"
