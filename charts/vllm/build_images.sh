#!/bin/bash

PUSH_LATEST=false
PIP_VLLM_VERSION=0.12.0
TEMPLATE_VERSION=1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --latest) PUSH_LATEST=true ;;
        --version) PIP_VLLM_VERSION="$2" ;;
        --template-version) TEMPLATE_VERSION="$2" ;;
    esac
    shift
done

PIP_VLLM_VERSION=${PIP_VLLM_VERSION:-"0.12.0"}
IMAGE_TAG="v${PIP_VLLM_VERSION}-${TEMPLATE_VERSION}"
CUDA_TAGS=(-t ghcr.io/kalavai-net/vllm-cuda:$IMAGE_TAG)
ROCM_TAGS=(-t ghcr.io/kalavai-net/vllm-rocm:$IMAGE_TAG)
CPU_TAGS=(-t ghcr.io/kalavai-net/vllm-cpu:$IMAGE_TAG)

echo "CUDA tags: $CUDA_TAGS"
if [ "$PUSH_LATEST" = true ]; then
  CUDA_TAGS+=(-t ghcr.io/kalavai-net/vllm-cuda:latest)
  ROCM_TAGS+=(-t ghcr.io/kalavai-net/vllm-rocm:latest)
  CPU_TAGS+=(-t ghcr.io/kalavai-net/vllm-cpu:latest)
fi

echo "Building vLLM version: $PIP_VLLM_VERSION"
echo "Pushing latest: $PUSH_LATEST"
echo "Image tag: ${IMAGE_TAG[@]}"
echo "CUDA tags: ${CUDA_TAGS[@]}"
echo "ROCM tags: ${ROCM_TAGS[@]}"
echo "CPU tags: ${CPU_TAGS[@]}"


# docker buildx build --build-arg VLLM_VERSION=$PIP_VLLM_VERSION --push \
#   "${CPU_TAGS[@]}" --platform=linux/amd64,linux/arm64 \
#   -f src/Dockerfile_cpu src/

# CUDA
# docker buildx build --build-arg VLLM_VERSION=$PIP_VLLM_VERSION --push \
#   "${CUDA_TAGS[@]}" --platform=linux/amd64,linux/arm64 \
#   -f src/Dockerfile_cuda src/



# ROCm
# build base image first
git clone https://github.com/vllm-project/vllm.git
cd vllm
git checkout releases/v$PIP_VLLM_VERSION
# DOCKER_BUILDKIT=1 docker build --build-arg BUILD_FA="0" -f docker/Dockerfile.rocm -t ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION .
# docker push ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION
# if [ "$PUSH_LATEST" = true ]; then
#     docker tag ghcr.io/kalavai-net/vllm-rocm-base:v$PIP_VLLM_VERSION ghcr.io/kalavai-net/vllm-rocm-base:latest
#     docker push ghcr.io/kalavai-net/vllm-rocm-base:latest
# fi
DOCKER_BUILDKIT=1 docker buildx build --build-arg BUILD_FA="0" --push \
  "${ROCM_TAGS[@]}" --platform=linux/amd64,linux/arm64 \
  -f docker/Dockerfile.rocm .
cd ..
rm -rf vllm
# docker build --build-arg VLLM_VERSION=v$PIP_VLLM_VERSION -t ghcr.io/kalavai-net/vllm-rocm:$IMAGE_TAG -f src/Dockerfile_rocm src/
# docker push ghcr.io/kalavai-net/vllm-rocm:$IMAGE_TAG
# if [ "$PUSH_LATEST" = true ]; then
#     docker tag ghcr.io/kalavai-net/vllm-rocm:$IMAGE_TAG ghcr.io/kalavai-net/vllm-rocm:latest
#     docker push ghcr.io/kalavai-net/vllm-rocm:latest
# fi
docker buildx build --build-arg VLLM_VERSION=$PIP_VLLM_VERSION --push \
  "${ROCM_TAGS[@]}" --platform=linux/amd64,linux/arm64 \
  -f src/Dockerfile_rocm src/

docker system prune -af
