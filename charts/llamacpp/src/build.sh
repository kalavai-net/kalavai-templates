#!/bin/bash

## Building llamacpp is required to avoid Illegal instruction errors
## Compiling it in runtime ensures the CPU will contain required instructions

subcommand=$1
CUDA_ARCHITECTURES="86;87;89;90"

shift
# GGML_RPC=ON: Builds RPC support
  # BUILD_SHARED_LIBS=OFF: Don't rely on shared libraries like libggml
  # use -DGGML_CUDA=ON for GPU support
  # use -DGGML_NATIVE=OFF for broader compatibility
  # use -DCMAKE_CUDA_ARCHITECTURES="70;75;80;86;87;89;90" to target broader CUDA architectures

case "$subcommand" in
  cpu)
    cd /workspace/llama.cpp
    #cmake -B build -DGGML_RPC=ON -DLLAMA_CURL=OFF -DLLAMA_BUILD_TESTS=OFF
    cmake -B build -DGGML_RPC=ON -DLLAMA_CURL=OFF -DLLAMA_BUILD_TESTS=OFF -DGGML_NATIVE=OFF
    cmake --build build --config Release -j $(nproc)
    ;;
  nvidia)
    cd /workspace/llama.cpp
    #cmake -B build -DGGML_RPC=ON -DGGML_CUDA=ON -DGGML_CUDA_ENABLE_UNIFIED_MEMORY=1 -DLLAMA_CURL=OFF -DLLAMA_BUILD_TESTS=OFF
    cmake -B build -DGGML_RPC=ON -DGGML_CUDA=ON -DGGML_CUDA_ENABLE_UNIFIED_MEMORY=1 -DLLAMA_CURL=OFF -DLLAMA_BUILD_TESTS=OFF -DGGML_NATIVE=OFF -DCMAKE_CUDA_ARCHITECTURES=$CUDA_ARCHITECTURES
    cmake --build build --config Release -j $(nproc)
    ;;
  amd)
    cd /workspace/llama.cpp
    HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
      cmake -S . -B build -DLLAMA_CURL=OFF -DGGML_HIP=ON -DGPU_TARGETS=gfx1100 -DCMAKE_BUILD_TYPE=Release -DLLAMA_BUILD_TESTS=OFF -DGGML_NATIVE=OFF \
      && cmake --build build --config Release -- -j $(nproc)
    ;;
  *)
    echo "unknown subcommand: $subcommand"
    exit 1
    ;;
esac