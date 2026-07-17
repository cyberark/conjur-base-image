#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

cd "$(dirname "$0")"

set -a # Marks all created or modified variables or functions for export.
source ../versions.env
set +a

ARCHITECTURE=$(../resolve_architecture.sh)

# Cap build-container CPUs on high-vCPU hosts (AmznDocker c6a.2xlarge). CNJR-13114:
# Ca-cert on FIPS-enabled AmznDocker is fixed in Dockerfile (OPENSSL_FORCE_FIPS_MODE=0
# on apt RUN only — not ENV; see docs/building-on-fips-enabled-hosts.md and LP #2066990).
# Cpuset/--cpus here is defense-in-depth for compile stages (make -j) only.
DOCKER_BUILD_CPUS="${DOCKER_BUILD_CPUS:-}"
if [ -z "${DOCKER_BUILD_CPUS}" ] && [ "$(nproc)" -gt 4 ]; then
  DOCKER_BUILD_CPUS=4
fi

docker_build_cpus_flag_supported() {
  local probe_dir
  probe_dir=$(mktemp -d)
  trap 'rm -rf "${probe_dir}"' RETURN
  cat > "${probe_dir}/Dockerfile" <<'EOF'
FROM ubuntu:24.04
RUN true
EOF
  DOCKER_BUILDKIT=0 docker build --cpus=1 -f "${probe_dir}/Dockerfile" "${probe_dir}" >/dev/null 2>&1
}

DOCKER_BUILD_CPU_ARGS=()
if [ -n "${DOCKER_BUILD_CPUS}" ]; then
  if docker_build_cpus_flag_supported; then
    DOCKER_BUILD_CPU_ARGS=(--cpus="${DOCKER_BUILD_CPUS}")
    echo "docker build mode: --cpus=${DOCKER_BUILD_CPUS} (engine supports build --cpus)"
  else
    export DOCKER_BUILDKIT=0
    DOCKER_BUILD_CPU_ARGS=(--cpuset-cpus="0-$((DOCKER_BUILD_CPUS - 1))")
    echo "docker build mode: legacy (DOCKER_BUILDKIT=0) with --cpuset-cpus=0-$((DOCKER_BUILD_CPUS - 1))"
  fi
  echo "build-container nproc probe: $(docker run --rm "${DOCKER_BUILD_CPU_ARGS[@]}" ubuntu:24.04 nproc 2>/dev/null || echo unknown)"
else
  echo "docker build mode: BuildKit (BUILDKIT_MAX_PARALLELISM=${BUILDKIT_MAX_PARALLELISM:-1})"
fi

function build() {
  set -e
  echo "building ${1} image from target ${2}"
  export BUILDKIT_MAX_PARALLELISM="${BUILDKIT_MAX_PARALLELISM:-1}"
  docker build \
    --platform "linux/${ARCHITECTURE}" \
    "${DOCKER_BUILD_CPU_ARGS[@]}" \
    --tag "${1}" \
    --target="${2}" \
    --pull \
    --build-arg UBUNTU_VERSION \
    --build-arg RUBY_FULL_VERSION \
    --build-arg RUBY_MAJOR_VERSION \
    --build-arg RUBY_SHA256 \
    --build-arg BUNDLER_VERSION \
    --build-arg PG_VERSION \
    --build-arg OPEN_SSL_FIPS_PROVIDER_VERSION \
    --build-arg OPEN_SSL_FIPS_PROVIDER_SHA256 \
    -f Dockerfile \
    ..
}

build "ubuntu-ruby-postgres-fips:latest-${ARCHITECTURE}" ubuntu-ruby-postgres-fips
build "ubuntu-ruby-fips:latest-${ARCHITECTURE}" ubuntu-ruby-fips-dev
build "ubuntu-ruby-builder:latest-${ARCHITECTURE}" ubuntu-ruby-builder
build "ubuntu-ruby-fips:slim-${ARCHITECTURE}" ubuntu-ruby-fips-slim

echo "Running docker container to generate description..."
OPENSSL_VERSION=$(docker run --rm "ubuntu-ruby-fips:latest-${ARCHITECTURE}" openssl version | tail -1 | sed 's/^.*[^0-9]\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/')
PG_VERSION=$(docker run --rm "ubuntu-ruby-fips:latest-${ARCHITECTURE}" psql --version | cut -d ' ' -f3)
export OPENSSL_VERSION
export PG_VERSION
./generate-description.sh
echo "Description generated and can be found in Description.md file"

set +e
