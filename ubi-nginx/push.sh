#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

NGINX_VERSION=1.14
LOCAL_IMAGE="ubi-nginx:latest"
IMAGE="conjur-nginx"
REDHAT_IMAGE="scan.connect.redhat.com/ospid-9a3dab9b-64c4-4384-882c-80f26ce98607/${IMAGE}"

if [[ -z "${TAG_NAME:-}" ]]; then
  # This script is NOT being run as part of a tag-triggered build
  # It will publish only to the internal registry on this run
  TAG="$(git rev-parse --short HEAD | tr -d '\n')"
  REGISTRY="$(normalize_repo_name $1)"

  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}"
else
  # The script is being run as part of a tag-triggered build
  # It will only publish to DockerHub on this run
  TAG="${TAG_NAME//"v"}"

  if summon -f ../secrets.yml bash -c 'docker login scan.connect.redhat.com -u unused -p "${REDHAT_API_KEY}"'; then
    tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${TAG}"
  else
    echo 'Failed to log in to scan.connect.redhat.com'
    exit 1
  fi
fi  
