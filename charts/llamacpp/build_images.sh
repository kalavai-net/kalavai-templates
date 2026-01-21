#!/bin/bash

docker build -t ghcr.io/kalavai-net/llamacpp-cpu:latest src/ -f src/Dockerfile_cpu
docker push ghcr.io/kalavai-net/llamacpp-cpu:latest
docker build -t ghcr.io/kalavai-net/llamacpp-cuda:latest src/ -f src/Dockerfile_cuda
docker push ghcr.io/kalavai-net/llamacpp-cuda:latest
docker build -t ghcr.io/kalavai-net/llamacpp-rocm:latest src/ -f src/Dockerfile_rocm
docker push ghcr.io/kalavai-net/llamacpp-rocm:latest