#!/bin/bash -e

cd "$(dirname "$0")"

FULL_IMAGE_NAME=""
TEST_FILE_NAME=""

while [ "$1" != "" ]; do
  case $1 in
  --full-image-name)
    shift
    FULL_IMAGE_NAME=$1
    ;;
  --test-file-name)
    shift
    TEST_FILE_NAME=$1
    ;;
  esac
  shift
done

if [ "$FULL_IMAGE_NAME" == "" ]; then
  echo "[--full-image-name] parameter is missing"
  exit 1
fi
if [ "$TEST_FILE_NAME" == "" ]; then
  echo "[--test-file-name] parameter is missing"
  exit 1
fi

REPORT_FILE_NAME="$(echo $(echo $FULL_IMAGE_NAME | cut -d':' -f1).$(echo $TEST_FILE_NAME | tr -d '.') | tr '/' '-').xml"

mkdir -p test-results

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD":/workspace \
  gcr.io/gcp-runtimes/container-structure-test:latest \
  test \
  --image "$FULL_IMAGE_NAME" \
  --output junit \
  --config "/workspace/$TEST_FILE_NAME" \
  --test-report "/workspace/test-results/$REPORT_FILE_NAME"
