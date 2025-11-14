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
  local arch="linux/$(../resolve_architecture.sh)"

  echo Tagging and pushing "$targetImage"...
  docker tag "$sourceImage" "$targetImage"
  docker push --platform "$arch" "$targetImage"
}

function create_and_push_manifest() {
  local sourceImageAmd="$1"
  local sourceImageArm="$2"
  local targetImage="$3"

  docker pull --platform linux/amd64 "$sourceImageAmd"
  docker pull --platform linux/arm64 "$sourceImageArm"

  echo Creating multiarch image: "$targetImage"...
  docker manifest create \
    --insecure \
    "$targetImage" \
    --amend "$sourceImageAmd" \
    --amend "$sourceImageArm"

  echo Pushing multiarch image: "$targetImage"...
  docker manifest push --insecure "$targetImage"

  # Because the bill of materials is created based on local docker images this is necessary in order to have
  # identical records in BOM files as previously, before multi-arch changes
  docker rmi "$sourceImageAmd"
  docker rmi "$sourceImageArm"
  docker pull "$targetImage"
}
