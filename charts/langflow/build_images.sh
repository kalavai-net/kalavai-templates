#!/bin/bash

PUSH_LATEST=false
TEMPLATE_VERSION=1

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --latest) PUSH_LATEST=true ;;
        --version) LANGFLOW_VERSION="$2" ;;
        --template-version) TEMPLATE_VERSION="$2" ;;
    esac
    shift
done

LANGFLOW_VERSION=${LANGFLOW_VERSION:-"1.12.6"}
IMAGE_TAG="v${LANGFLOW_VERSION}-${TEMPLATE_VERSION}"

echo "Building Langflow version: $LANGFLOW_VERSION"
echo "Pushing latest: $PUSH_LATEST"
echo "Image tag: $IMAGE_TAG"

docker buildx build --build-arg LANGFLOW_VERSION=$LANGFLOW_VERSION --push -t ghcr.io/kalavai-net/langflow:$IMAGE_TAG --platform=linux/amd64,linux/arm64 -f src/Dockerfile src/
if [ "$PUSH_LATEST" = true ]; then
    docker buildx build --build-arg LANGFLOW_VERSION=$LANGFLOW_VERSION --push -t ghcr.io/kalavai-net/langflow:latest --platform=linux/amd64,linux/arm64 -f src/Dockerfile src/
fi

# free disk space
docker system prune -af
