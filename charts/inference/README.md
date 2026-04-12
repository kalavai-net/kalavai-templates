Fault tolerance: 
https://docs.ray.io/en/latest/serve/production-guide/fault-tolerance.html
https://docs.ray.io/en/latest/cluster/kubernetes/user-guides/rayservice-high-availability.html#step-3-install-a-rayservice-with-gcs-fault-tolerance

Cluster Autoscaling:



Model autoscaling:

https://docs.ray.io/en/latest/serve/autoscaling-guide.html
Config: https://docs.ray.io/en/latest/serve/api/doc/ray.serve.config.AutoscalingConfig.html#ray.serve.config.AutoscalingConfig


Moving to a different backend (llama cpp) involves using the low leve RayServe API:

The code below handles:

Autoscaling to zero (min_replicas: 0).

Multi-node/Multi-GPU orchestration (assigning workers to specific GPUs).

Llama.cpp RPC integration (connecting the leader to the workers).

```python
import ray
from ray import serve
from fastapi import FastAPI
import subprocess
import time

app = FastAPI()

# 1. Define a simple Worker Actor that will run the llama-rpc-server
@ray.remote
class LlamaRPCWorker:
    def __init__(self):
        # Start the llama-cpp rpc-server on this worker node
        # Ensure 'rpc-server' is in your PATH and compiled with CUDA
        self.process = subprocess.Popen(
            ["rpc-server", "-p", "50052", "-H", "0.0.0.0"]
        )
        print(f"RPC Worker started on {ray.get_runtime_context().get_node_id()}")

    def get_ip(self):
        return ray.util.get_node_ip_address()

# 2. Define the main Serve Deployment (The "Leader")
@serve.deployment(
    autoscaling_config={
        "min_replicas": 0, 
        "max_replicas": 2,
        "target_ongoing_requests": 1,
    },
    # This defines the physical layout of ONE replica.
    # Bundle 0 is for the Leader, Bundle 1+ are for Workers.
    placement_group_bundles=[
        {"CPU": 2, "GPU": 1}, # Bundle 0 (Leader)
        {"CPU": 2, "GPU": 1}, # Bundle 1 (Worker 1)
    ],
    placement_group_strategy="STRICT_SPREAD", # Ensures workers land on different nodes
)
@serve.ingress(app)
class DistributedLlamaDeployment:
    def __init__(self, model_path: str):
        from llama_cpp import Llama
        
        # Start the worker on the second bundle of this replica's placement group
        self.worker = LlamaRPCWorker.options(
            num_gpus=1,
            scheduling_strategy=ray.util.scheduling_strategies.PlacementGroupSchedulingStrategy(
                placement_group=ray.util.get_current_placement_group(),
                placement_group_bundle_index=1,
            )
        ).remote()
        
        worker_ip = ray.get(self.worker.get_ip.remote())
        
        # Initialize llama.cpp and point it to the RPC worker
        self.llm = Llama(
            model_path=model_path,
            n_gpu_layers=-1, # Offload all to GPUs
            rpc_servers=f"{worker_ip}:50052"
        )

    @app.post("/v1/completions")
    async def generate(self, prompt: str):
        return self.llm(prompt, max_tokens=100)

# 3. Bind and Deploy
# The model path must be accessible (e.g., shared NFS or baked into image)
entrypoint = DistributedLlamaDeployment.bind("/models/my_model.gguf")
```

To avoid reimplementing the entire OpenAPI api: https://github.com/poe-platform/fastapi_poe?tab=readme-ov-file
