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

function tag_and_push_channels() {
  local sourceImage="$1"
  local targetImage="$2"
  local buildTag="$3"

  CHANNEL_TAGS=${CHANNEL_TAGS:-""}

  tag_and_push "${sourceImage}" "${targetImage}:${buildTag}"

  for tag in ${CHANNEL_TAGS}; do
    tag_and_push "${sourceImage}" "${targetImage}:${tag}"
  done
}

function main_tag_and_push() {
  local sourceImage="$1"
  local targetImageName="$2"
  local imageBaseVersion="$3"

  readonly TAGS=(
    "${imageBaseVersion}"
    "latest"
  )

  for tag in "${TAGS[@]}" $(gen_versions "${imageBaseVersion}"); do
    tag_and_push "${sourceImage}" "${targetImageName}:${tag}"
  done

}

# generate less specific versions, eg. given 1.2.3 will print 1.2 and 1
# (note: the argument itself is not printed, append it explicitly if needed)
function gen_versions() {
  local version=$1
  while [[ $version = *.* ]]; do
    version=${version%.*}
    echo $version
  done
}
