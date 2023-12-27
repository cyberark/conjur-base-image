#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

# ${1} - image name
# ${2} - tag suffix
function push_image() {
  IMAGE="registry.tld/cyberark/${1}"
  TAG=$(<../VERSION)
  HASH=$(git log -1 --pretty=format:%h)

  create_and_push_manifest \
    "${IMAGE}:${TAG}-${HASH}${2}-amd64" \
    "${IMAGE}:${TAG}-${HASH}${2}-arm64" \
    "${IMAGE}:${TAG}-${HASH}${2}"
}

push_image "ubuntu-ruby-builder" ""
push_image "ubuntu-ruby-fips"  ""
push_image "ubuntu-ruby-postgres-fips"  ""
push_image "ubuntu-ruby-fips"  "-slim"