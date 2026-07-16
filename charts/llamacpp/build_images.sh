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

docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cuda src/
if [ "$PUSH_LATEST" = true ]; then
    docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-cuda:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cuda src/
fi

# docker build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION -t ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG src/ -f src/Dockerfile_cuda
# docker push ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG
# if [ "$PUSH_LATEST" = true ]; then
#     docker tag ghcr.io/kalavai-net/llamacpp-cuda:$IMAGE_TAG ghcr.io/kalavai-net/llamacpp-cuda:latest
#     docker push ghcr.io/kalavai-net/llamacpp-cuda:latest
# fi

docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cpu src/
if [ "$PUSH_LATEST" = true ]; then
    docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-cpu:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cpu src/
fi

# docker build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION -t ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG src/ -f src/Dockerfile_cpu
# docker push ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG
# if [ "$PUSH_LATEST" = true ]; then
#     docker tag ghcr.io/kalavai-net/llamacpp-cpu:$IMAGE_TAG ghcr.io/kalavai-net/llamacpp-cpu:latest
#     docker push ghcr.io/kalavai-net/llamacpp-cpu:latest
# fi

# docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-rocm:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile_rocm src/
# if [ "$PUSH_LATEST" = true ]; then
#     docker buildx build --build-arg LLAMACPP_VERSION=$LLAMACPP_VERSION --push -t ghcr.io/kalavai-net/llamacpp-rocm:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile_rocm src/
# fi