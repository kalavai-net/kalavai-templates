#!/bin/bash

PUSH_LATEST=false
LLAMACPP_VERSION=master
TEMPLATE_VERSION=1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --latest) PUSH_LATEST=true ;;
        --version) LLAMACPP_VERSION="$2" ;;
        --template-version) TEMPLATE_VERSION="$2" ;;
    esac
    shift
done

LLAMACPP_VERSION=${LLAMACPP_VERSION:-"master"}
IMAGE_TAG="${LLAMACPP_VERSION}-${TEMPLATE_VERSION}"

echo "Building Llama.cpp version: $LLAMACPP_VERSION"
echo "Pushing latest: $PUSH_LATEST"
echo "Image tag: $IMAGE_TAG"


docker build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION -t ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG src/ -f src/Dockerfile_cuda
docker push ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG
if [ "$PUSH_LATEST" = true ]; then
    docker tag ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG ghcr.io/kalavai-net/llamacpp-cuda:latest
    docker push ghcr.io/kalavai-net/llamacpp-cuda:latest
fi

docker build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION -t ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG src/ -f src/Dockerfile_cpu
docker push ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG
if [ "$PUSH_LATEST" = true ]; then
    docker tag ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG ghcr.io/kalavai-net/llamacpp-cpu:latest
    docker push ghcr.io/kalavai-net/llamacpp-cpu:latest
fi

# docker build -t ghcr.io/kalavai-net/llamacpp-rocm:$IMAGE_TAG src/ -f src/Dockerfile_rocm
# docker push ghcr.io/kalavai-net/llamacpp-rocm:$IMAGE_TAG