#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

UBI_VERSION=ubi8

if [ "$BRANCH_NAME" = "master" ]; then
  tag_and_push "ubi-ruby-fips:$1" "registry.tld/cyberark/ubi-ruby-fips:$UBI_VERSION-$1"
  
  repoName="$(normalize_repo_name $2)cyberark"
  master_tag_and_push "ubi-ruby-fips:$1" "$repoName/ubi-ruby-fips" "$UBI_VERSION"
else
  tag_and_push "ubi-ruby-fips:$1" "registry.tld/cyberark/ubi-ruby-fips:$UBI_VERSION-$1"
fi