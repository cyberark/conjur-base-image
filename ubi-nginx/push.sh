#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

NGINX_VERSION=1.14
REDHAT_IMAGE="scan.connect.redhat.com/ospid-9a3dab9b-64c4-4384-882c-80f26ce98607/conjur-nginx"

tag=$1
repo_name=$2

# No matter what, publish to the internal registry
tag_and_push "ubi-nginx:${tag}" "registry.tld/cyberark/ubi-nginx:${NGINX_VERSION}-${tag}"

if [ -z "${repo_name}" ]; then
  # Publish production images
  if summon -f ../secrets.yml bash -c 'docker login scan.connect.redhat.com -u unused -p "${REDHAT_API_KEY}"'; then
    master_tag_and_push "ubi-nginx:${tag}" "${REDHAT_IMAGE}" "${NGINX_VERSION}"
  else
    echo 'Failed to log in to scan.connect.redhat.com'
    exit 1
  fi
fi
