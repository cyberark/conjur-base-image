#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

ARCHITECTURE=$(../resolve_architecture.sh)

# ${1} - image name
# ${2} - image tag
# ${3} - tag suffix
function push_image() {
  LOCAL_IMAGE="${1}:${2}-${ARCHITECTURE}"
  IMAGE="registry.tld/cyberark/${1}"
  TAG=$(<../VERSION)
  HASH=$(git log -1 --pretty=format:%h)

  tag_and_push "${LOCAL_IMAGE}" "${IMAGE}:${TAG}-${HASH}${3}-${ARCHITECTURE}"
}

push_image "ubuntu-ruby-builder" "latest" ""
push_image "ubuntu-ruby-fips" "latest" ""
push_image "ubuntu-ruby-postgres-fips" "latest" ""
push_image "ubuntu-ruby-fips" "slim" "-slim"