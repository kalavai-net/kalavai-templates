# kalavai-templates

Pre built templates to deploy in [Kalavai pools](https://github.com/kalavai-net/kalavai-client) and Kubernetes clusters.

## How to install

To deploy kalavai templates in Kubernetes, you need to install the kalavai-templates helm chart. Note that you **do not need to install the chart if you are running a Kalavai pool** as this is already pre configured.

Add the repo to your helm:

```bash
helm repo add kalavai-templates https://kalavai-net.github.io/kalavai-templates/
helm repo update
```

## How to deploy

To deploy a template in your Kubernetes cluster:

```bash
helm install my-release kalavai-templates/<template_name> --values values.yaml
```

See the list of available templates [here](#available-templates).


## Available templates

List of templates, by name:

- [vllm](./charts/vllm/)
- [ray-cluster](./charts/raycluster/)

Each folder contains examples of config yaml (as `values_example.yaml`) to show how to deploy and setup a template.