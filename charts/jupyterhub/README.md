Base: https://github.com/kalavai-net/kalavai-deployments/tree/main/kalavai-core/jupyterhub

Chart default values: https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/HEAD/jupyterhub/values.yaml


# Install jupyterhub

helm upgrade --cleanup-on-fail \
  --install hub jupyterhub/jupyterhub \
  --namespace jh \
  --create-namespace \
  --version=4.3.2 \
  --values jupyter_config.yaml


# Install coder

https://coder.com/docs/install/kubernetes


```bash
kubectl apply -f coder_deps.yaml
helm repo add coder-v2 https://helm.coder.com/v2
helm repo update
helm install coder oci://ghcr.io/coder/chart/coder \
    --namespace coder \
    --create-namespace \
    --values coder_values.yaml \
    --version 2.29.5
```
