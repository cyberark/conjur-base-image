#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

NGINX_VERSION=1.20
LOCAL_IMAGE="ubi-nginx:latest"
IMAGE="conjur-nginx"
readonly REDHAT_REGISTRY="quay.io"

prefixless='9a3dab9b-64c4-4384-882c-80f26ce98607'
user="redhat-isv-containers+${prefixless}-robot"
echo "DEBUG: prefixless (without ospid): ${prefixless}"
echo "DEBUG: Login to red hat with user: ${user}"
echo "DEBUG: ${REDHAT_REGISTRY}"

REDHAT_IMAGE="${REDHAT_REGISTRY}/redhat-isv-containers/${prefixless}/${IMAGE}"
REGISTRY="$(normalize_repo_name "$1")"
TAG=$(<../VERSION)

if [[ -z "${REGISTRY:-}" ]]; then
  # Push to public registry with VERSION
  if summon -f ../secrets.yml bash -c 'docker login "${REDHAT_REGISTRY}" -u "${user}" -p "${REDHAT_API_KEY}"'; then
    tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${TAG}"
  else
    echo 'Failed to log in to scan.connect.redhat.com'
    exit 1
  fi
else
  # Push to internal locations with VERSION and image versions
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}-${TAG}"
  tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}"
fi
