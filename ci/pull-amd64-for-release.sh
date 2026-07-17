#!/bin/bash -e

# Pull amd64 images from the internal registry and retag them as the local
# latest-amd64 tags expected by push.sh. Used on RELEASE when publish runs on a
# fresh AmznDocker worker after the build worker has terminated.

cd "$(dirname "$0")/.."

. push.sh

ARCHITECTURE=$(./resolve_architecture.sh)
TAG=$(<VERSION)
HASH=$(read_git_sha)
BUILT_VERSION="${TAG}-${HASH}"
PLATFORM="linux/${ARCHITECTURE}"

pull_and_retag() {
  local registry_image="$1"
  local local_image="$2"

  echo "Pulling ${registry_image} -> ${local_image}"
  docker_pull_platform_image "${PLATFORM}" "${registry_image}"
  docker tag "${registry_image}" "${local_image}"
}

pull_and_retag "registry.tld/cyberark/ubuntu-ruby-builder:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubuntu-ruby-builder:latest-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubuntu-ruby-fips:latest-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubuntu-ruby-postgres-fips:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubuntu-ruby-postgres-fips:latest-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubuntu-ruby-fips:${BUILT_VERSION}-slim-${ARCHITECTURE}" \
  "ubuntu-ruby-fips:slim-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubi-ruby-builder:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubi-ruby-builder:latest-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubi-ruby-fips:latest-${ARCHITECTURE}"
pull_and_retag "registry.tld/cyberark/ubi-ruby-fips:${BUILT_VERSION}-slim-${ARCHITECTURE}" \
  "ubi-ruby-fips:slim-${ARCHITECTURE}"
pull_and_retag "registry.tld/conjur-nginx:${BUILT_VERSION}-${ARCHITECTURE}" \
  "ubi-nginx:latest-${ARCHITECTURE}"
