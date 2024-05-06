#!/bin/bash

# Returns the machine architecture for the current platform.
# Takes into account the DOCKER_DEFAULT_PLATFORM environment variable.
get_machine_architecture() {
  local architecture
  if [[ -n "${DOCKER_DEFAULT_PLATFORM:-}" ]]; then
    # Take part after the slash (e.g. linux/amd64 -> amd64)
    architecture="${DOCKER_DEFAULT_PLATFORM##*/}"
  else
    architecture="$(uname -m)"
  fi

  case "$architecture" in
    x86_64 | amd64)
      echo "amd64"
      ;;
    aarch64 | arm64)
      echo "arm64"
      ;;
    *)
      echo "amd64"
      ;;
  esac
}

get_machine_architecture
