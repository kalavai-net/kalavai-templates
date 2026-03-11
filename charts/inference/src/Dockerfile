# https://github.com/ray-project/ray/blob/master/docker/ray-llm/Dockerfile

FROM python:3.11-slim

# Install system dependencies required by Ray LLM
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    kmod \
    pkg-config \
    librdmacm-dev \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Install core Python dependencies
# may need 2.52.0 and vllm 0.14.0 for vllm.entrypoints.openai.protocol 
RUN pip install "ray[serve]==2.54.0" vllm==0.16.0 pyarrow --no-cache-dir

# Install additional Ray LLM dependencies
RUN pip install \
    pandas \
    numpy \
    requests \
    transformers \
    tokenizers \
    huggingface_hub \
    torch \
    torchvision \
    boto3 \
    --no-cache-dir

