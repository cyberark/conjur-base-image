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
TEXT_REPORT_FILE_NAME="${REPORT_FILE_NAME%.xml}.cst.txt"

mkdir -p test-results

STRUCTURE_TEST_IMAGE="gcr.io/gcp-runtimes/container-structure-test:latest"
STRUCTURE_TEST_ARGS=(
  -v /var/run/docker.sock:/var/run/docker.sock
  -v "$PWD":/workspace
  "$STRUCTURE_TEST_IMAGE"
  test
  --image "$FULL_IMAGE_NAME"
  --config "/workspace/$TEST_FILE_NAME"
)

echo "=== container-structure-test (text) for $FULL_IMAGE_NAME ==="
docker run --rm \
  "${STRUCTURE_TEST_ARGS[@]}" \
  --output text 2>&1 | tee "test-results/$TEXT_REPORT_FILE_NAME"
test_exit=${PIPESTATUS[0]}

if [ "$test_exit" -eq 0 ]; then
  docker run --rm \
    "${STRUCTURE_TEST_ARGS[@]}" \
    --output junit \
    --test-report "/workspace/test-results/$REPORT_FILE_NAME"
  exit 0
fi

echo "=== container-structure-test FAILED for $FULL_IMAGE_NAME (exit $test_exit) ==="
exit "$test_exit"
