#!/bin/bash

IMAGE_TAG="latest"
PUSH_LATEST="false"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --latest) PUSH_LATEST=true ;;
        --version) IMAGE_TAG="$2" ;;
    esac
    shift
done

echo "Building JupyterHub version: $IMAGE_TAG"
echo "Pushing latest: $PUSH_LATEST"

# CUDA
docker buildx build --push -t ghcr.io/kalavai-net/jupyterhub-cuda:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cuda src/
if [ "$PUSH_LATEST" = true ]; then
    docker buildx build --push -t ghcr.io/kalavai-net/jupyterhub-cuda:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cuda src/
fi

# CPU
docker buildx build --push -t ghcr.io/kalavai-net/jupyterhub-cpu:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cpu src/
if [ "$PUSH_LATEST" = true ]; then
    docker buildx build --push -t ghcr.io/kalavai-net/jupyterhub-cpu:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile_cpu src/
fi
