#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

PHUSION_VERSION=0.11


if [ "$BRANCH_NAME" = "master" ]; then
  tag_and_push "phusion-ruby-fips:$1" "registry.tld/cyberark/phusion-ruby-fips:$PHUSION_VERSION-$1"
  
  repoName="$(normalize_repo_name $2)cyberark"
  master_tag_and_push "phusion-ruby-fips:$1" "$repoName/phusion-ruby-fips" "$PHUSION_VERSION"
else
  tag_and_push "phusion-ruby-fips:$1" "registry.tld/cyberark/phusion-ruby-fips:$PHUSION_VERSION-$1"
fi

