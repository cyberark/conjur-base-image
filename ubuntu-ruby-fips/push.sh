#!/bin/bash -e

cd "$(dirname "$0")"

. ../push.sh

UBUNTU_VERSION=20.04


if [ "$BRANCH_NAME" = "master" ]; then
  tag_and_push "ubuntu-ruby-fips:$1" "registry.tld/cyberark/ubuntu-ruby-fips:$UBUNTU_VERSION-$1"
  
  repoName="$(normalize_repo_name $2)cyberark"
  master_tag_and_push "ubuntu-ruby-fips:$1" "$repoName/ubuntu-ruby-fips" "$UBUNTU_VERSION"
else
  tag_and_push "ubuntu-ruby-fips:$1" "registry.tld/cyberark/ubuntu-ruby-fips:$UBUNTU_VERSION-$1"
fi
