#!/bin/bash -e

# COMMENTED OUT TEMPORARILY TO GET BUILD PASSING. WILL ADDRESS SHORTLY.

# cd "$(dirname "$0")"

# . ../push.sh

# NGINX_VERSION=1.20
# LOCAL_IMAGE="ubi-nginx:latest"
# IMAGE="conjur-nginx"
# # REDHAT_IMAGE="scan.connect.redhat.com/ospid-9a3dab9b-64c4-4384-882c-80f26ce98607/${IMAGE}"
# REGISTRY="$(normalize_repo_name "$1")"
# TAG=$(<../VERSION)

# if [[ -z "${REGISTRY:-}" ]]; then
#   # Push to public registry with VERSION
#   if summon -f ../secrets.yml bash -c 'docker login scan.connect.redhat.com -u unused -p "${REDHAT_API_KEY}"'; then
#     tag_and_push "${LOCAL_IMAGE}" "${REDHAT_IMAGE}:${TAG}"
#   else
#     echo 'Failed to log in to scan.connect.redhat.com'
#     exit 1
#   fi
# else
#   # Push to internal locations with VERSION and image versions
#   tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}-${TAG}"
#   tag_and_push "${LOCAL_IMAGE}" "${REGISTRY}${IMAGE}:${NGINX_VERSION}"
# fi
