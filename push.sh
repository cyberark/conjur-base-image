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

function master_tag_and_push() {

  local sourceImage="$1"
  local targetImageName="$2"
  local imageBaseVersion="$3"

  TAGS=(
    "$imageBaseVersion-latest"
    "latest"
  )

  for t in "${TAGS[@]}"
  do
    tag_and_push $sourceImage "$targetImageName:$t"
  done

}
