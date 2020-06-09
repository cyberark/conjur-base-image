#!/bin/bash -e

function tag_and_push() {
  local tag="$1"
  shift

  for image in $*; do
    local target=$image:$tag
    echo Tagging and pushing $target...
    docker tag "$SOURCE_IMAGE" $target
    docker push $target
  done
}

IMAGE_NAME=""
IMAGE_TAG=""
IMAGE_BASE_VERSION=""

while [ "$1" != "" ]; do
  case $1 in
    --image-name )  shift
      IMAGE_NAME=$1
      ;;
    --image-tag )  shift
      IMAGE_TAG=$1
      ;;
    --image-base-version )  shift
      IMAGE_BASE_VERSION=$1
      ;;
  esac
  shift
done

if [ "$IMAGE_NAME" == "" ]; then
  echo "[--image-name] parameter is missing"
  exit 1
fi
if [ "$IMAGE_TAG" == "" ]; then
  echo "[--image-tag] parameter is missing"
  exit 1
fi
if [ "$IMAGE_BASE_VERSION" == "" ]; then
  echo "[--image-base-version] parameter is missing"
  exit 1
fi

INTERNAL_VERSION="$IMAGE_BASE_VERSION-$IMAGE_TAG"
VERSION="$IMAGE_BASE_VERSION-$(date +%Y%m%d)-$IMAGE_TAG"
SOURCE_IMAGE="$IMAGE_NAME:$IMAGE_TAG"

CONJUR_REGISTRY=registry.tld

INTERNAL_IMAGES="$CONJUR_REGISTRY/cyberark/$IMAGE_NAME"

# always push VERSION-SHA tags to our registry
tag_and_push $INTERNAL_VERSION $INTERNAL_IMAGES

if [ "$BRANCH_NAME" = "master" ]; then

  TAGS=(
    "$IMAGE_BASE_VERSION-$(date +%Y%m%d)"
    "$IMAGE_BASE_VERSION-latest"
    "latest"
  )

  for t in "${TAGS[@]}"
  do
    tag_and_push $t $INTERNAL_IMAGES
  done

fi
