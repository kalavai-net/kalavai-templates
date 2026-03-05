#!/bin/bash

PUSH_LATEST=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --latest) PUSH_LATEST=true ;;
        --version) PIP_VLLM_VERSION="$2" ;;
    esac
    shift
done

PIP_VLLM_VERSION=${PIP_VLLM_VERSION:-"0.12.0"}

echo "Building vLLM version: $PIP_VLLM_VERSION"
echo "Pushing latest: $PUSH_LATEST"

# CUDA
docker build --build-arg PIP_VLLM_VERSION=$PIP_VLLM_VERSION -t ghcr.io/kalavai-net/vllm-cuda:v$PIP_VLLM_VERSION -f src/Dockerfile_cuda src/
docker push ghcr.io/kalavai-net/vllm-cuda:v$PIP_VLLM_VERSION
if [ "$PUSH_LATEST" = true ]; then
    docker tag ghcr.io/kalavai-net/vllm-cuda:v$PIP_VLLM_VERSION ghcr.io/kalavai-net/vllm-cuda:latest
    docker push ghcr.io/kalavai-net/vllm-cuda:latest
fi

# free disk space
docker system prune -af

# ROCm
# build base image first
git clone https://github.com/vllm-project/vllm.git
cd vllm
git checkout releases/v$PIP_VLLM_VERSION
DOCKER_BUILDKIT=1 docker build --build-arg BUILD_FA="0" -f docker/Dockerfile.rocm -t ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION .
docker push ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION
if [ "$PUSH_LATEST" = true ]; then
    docker tag ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION ghcr.io/kalavai-net/vllm-rocm-base:latest
    docker push ghcr.io/kalavai-net/vllm-rocm-base:latest
fi
cd ..
rm -rf vllm

docker system prune -af

docker build --build-arg VLLM_VERSION=v$PIP_VLLM_VERSION -t ghcr.io/kalavai-net/vllm-rocm:v$PIP_VLLM_VERSION -f src/Dockerfile_rocm src/
docker push ghcr.io/kalavai-net/vllm-rocm:v$PIP_VLLM_VERSION
if [ "$PUSH_LATEST" = true ]; then
    docker tag ghcr.io/kalavai-net/vllm-rocm:v$PIP_VLLM_VERSION ghcr.io/kalavai-net/vllm-rocm:latest
    docker push ghcr.io/kalavai-net/vllm-rocm:latest
fi
