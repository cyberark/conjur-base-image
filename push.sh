#!/bin/bash -e

function normalize_repo_name() {
  local repoName="$1"
  if [ "$repoName" != "" ] && [ "${repoName: -1}" != "/" ]; then
    repoName="$repoName/"
  fi
  echo -n "$repoName"
}

function tag_and_push() {
  local sourceImage="$1"
  local targetImage="$2"

  echo Tagging and pushing $targetImage...
  docker tag "$sourceImage" $targetImage
  docker push $targetImage
}
