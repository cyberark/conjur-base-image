#!/bin/bash -e

# Orchestrator writes GIT_SHA during Prepare; remote agents may resolve a different
# PR merge commit if they run git log locally.
function read_git_sha() {
  local sha_file="GIT_SHA"
  if [[ ! -f "${sha_file}" && -f "../GIT_SHA" ]]; then
    sha_file="../GIT_SHA"
  fi
  if [[ -f "${sha_file}" ]]; then
    tr -d '[:space:]' < "${sha_file}"
  else
    git log -1 --pretty=format:%h
  fi
}

function normalize_repo_name() {
  local repoName="$1"
  if [ "$repoName" != "" ] && [ "${repoName: -1}" != "/" ]; then
    repoName="$repoName/"
  fi
  echo -n "$repoName"
}

function docker_push_supports_platform() {
  docker push --help 2>&1 | grep -q -- '--platform'
}

function docker_pull_supports_platform() {
  docker pull --help 2>&1 | grep -q -- '--platform'
}

function docker_push_image() {
  local arch="$1"
  local targetImage="$2"

  if docker_push_supports_platform; then
    docker push --platform "$arch" "$targetImage"
  else
    # AL2023 docker 25.x: native single-arch tags do not need --platform (requires API 1.46+).
    docker push "$targetImage"
  fi
}

function docker_pull_platform_image() {
  local platform="$1"
  local image="$2"

  if docker_pull_supports_platform; then
    docker pull --platform "$platform" "$image"
  else
    docker pull "$image"
  fi
}

function tag_and_push() {
  local sourceImage="$1"
  local targetImage="$2"
  local arch="linux/$(../resolve_architecture.sh)"

  echo Tagging and pushing "$targetImage"...
  docker tag "$sourceImage" "$targetImage"
  docker_push_image "$arch" "$targetImage"
}

function create_and_push_manifest() {
  local sourceImageAmd="$1"
  local sourceImageArm="$2"
  local targetImage="$3"

  docker_pull_platform_image linux/amd64 "$sourceImageAmd"
  docker_pull_platform_image linux/arm64 "$sourceImageArm"

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
