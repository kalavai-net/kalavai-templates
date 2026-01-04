#!/bin/bash

PIP_VLLM_VERSION=${1:-"0.11.2"}

echo "Building vLLM version: $PIP_VLLM_VERSION"

# CUDA
docker build --build-arg PIP_VLLM_VERSION=$PIP_VLLM_VERSION -t kalavai/ray-vllm-cuda:v$PIP_VLLM_VERSION -f Dockerfile_cuda .
docker push kalavai/ray-vllm-cuda:v$PIP_VLLM_VERSION

# ROCm
# build base image first
git clone https://github.com/vllm-project/vllm.git
cd vllm
git checkout releases/v$PIP_VLLM_VERSION
DOCKER_BUILDKIT=1 docker build --build-arg BUILD_FA="0" -f docker/Dockerfile.rocm -t kalavai/vllm-rocm:v$PIP_VLLM_VERSION .
docker push kalavai/vllm-rocm:v$PIP_VLLM_VERSION
cd ..

docker build --build-arg VLLM_VERSION=v$PIP_VLLM_VERSION -t kalavai/ray-vllm-rocm:v$PIP_VLLM_VERSION -f Dockerfile_rocm .
docker push kalavai/ray-vllm-rocm:v$PIP_VLLM_VERSION