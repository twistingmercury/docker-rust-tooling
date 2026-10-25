#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IS_LOCAL="${IS_LOCAL:-0}"
IMAGE_NAME=ghcr.io/twistingmercury/rust-tooling
# the Dockerfile FROM line is the source of truth, so the tag always matches the base
RUST_VERSION="rust$(sed -nE 's/^FROM rust:([0-9.]+)-slim.*/\1/p' "${SCRIPT_DIR}/Dockerfile")"
BUILD_DATE="${BUILD_DATE:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
BUILD_COMMIT="${BUILD_COMMIT:-$(git -C "${SCRIPT_DIR}" rev-parse --short HEAD 2>/dev/null || echo 'unknown')}"

cleanup_local_image() {
    local exit_status=$?

    if [[ "${IS_LOCAL}" == "1" ]]; then
        docker rmi "${IMAGE_NAME}:${RUST_VERSION}" "${IMAGE_NAME}:latest" -f || true
    fi

    exit "${exit_status}"
}

main(){
    trap cleanup_local_image EXIT

    docker build --rm --no-cache --pull --progress=plain \
    --build-arg BUILD_DATE="${BUILD_DATE}" \
    --build-arg VCS_REF="${BUILD_COMMIT}" \
    --build-arg VERSION="${RUST_VERSION#rust}" \
    -t "${IMAGE_NAME}:${RUST_VERSION}" \
    -t "${IMAGE_NAME}:latest" "${SCRIPT_DIR}"
}

main "$@"
