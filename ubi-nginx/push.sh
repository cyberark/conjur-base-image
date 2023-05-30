#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

LOCAL_IMAGE="ubi-nginx:latest"
IMAGE="conjur-nginx"
readonly REDHAT_REGISTRY="quay.io"

# This ID is the one shown in the URL for the project, not the PID/OSPID
prefixless='5f9052d3796c8e8debd8ee29'

user="redhat-isv-containers+${prefixless}-robot"
echo "DEBUG: prefixless (without ospid): ${prefixless}"
echo "DEBUG: Login to red hat with user: ${user}"
echo "DEBUG: ${REDHAT_REGISTRY}"

REDHAT_IMAGE="${REDHAT_REGISTRY}/redhat-isv-containers/${prefixless}"
REGISTRY="$(normalize_repo_name "$1")"
TAG=$(<../VERSION)

if [[ -z "${REGISTRY:-}" ]]; then
  # Push to public registry with UBI version and and image versions
  if summon -f ../secrets.yml bash -c "docker login ${REDHAT_REGISTRY} -u ${user} -p \${REDHAT_API_KEY}"; then
    tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${UBI_VERSION}-${TAG}"
    tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${UBI_VERSION}"
    tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${TAG}"
    "./bin/scan_redhat_image" "${REDHAT_IMAGE}:${TAG}" "${prefixless}"
  else
    echo 'Failed to log in to quay.io'
    exit 1
  fi
else
  # Push to internal locations with UBI version and and image versions
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBI_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${UBI_VERSION}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:latest"
fi
