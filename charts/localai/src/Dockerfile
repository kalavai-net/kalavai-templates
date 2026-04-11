# build from source
FROM golang:1.26.1-bookworm

ARG GRPC_VERSION="v1.65.0"
ARG CUDA_VERSION="12-8"

WORKDIR /workspace

# dependencies
RUN apt-get update \
    && apt-get install -y unzip npm nodejs software-properties-common git wget curl build-essential ffmpeg protobuf-compiler ccache gawk cmake libgmock-dev

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# cuda
RUN curl -O https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i cuda-keyring_1.1-1_all.deb && \
    apt-get update && \
    apt-get install -y cuda-nvcc-$CUDA_VERSION libcublas-dev-$CUDA_VERSION

# grpc
RUN git clone --recurse-submodules -b $GRPC_VERSION --depth 1 --shallow-submodules https://github.com/grpc/grpc && \
    cd grpc && sed -i "216i\  TESTONLY" "third_party/abseil-cpp/absl/container/CMakeLists.txt" && mkdir -p cmake/build && \
    cd cmake/build && \
    cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF ../.. && \ 
    make -j $(nproc) --output-sync=target
RUN cd grpc && cd cmake/build && make -j $(nproc) --output-sync=target install

# build localai
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@1958fcbe2ca8bd93af633f11e97d44e567e945af
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.34.2
ENV GOPATH=/root/go/bin
ENV PATH=$PATH:$GOPATH/bin
ENV PATH=/usr/local/cuda/bin:$PATH
#source /opt/intel/oneapi/setvars.sh
RUN cp /lib64/ld-linux-x86-64.so.2 ld.so

RUN git clone https://github.com/mudler/LocalAI
WORKDIR /workspace/LocalAI

# try skipping all backends, then use only external llamacpp
RUN make BUILD_GRPC_FOR_BACKEND_LLAMA=true GRPC_BACKENDS=backend-assets/grpc/llama-cpp IMAGE_TYPE=core CUDA_LIBPATH=/usr/local/cuda/lib64 -j $(nproc) build
RUN cp ./local-ai /workspace/local-ai

WORKDIR /workspace

COPY get_workers_address.sh .
RUN chmod +x /workspace/get_workers_address.sh