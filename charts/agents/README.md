# Agent platform

BerryAI/LiteLLM agent platform
- comes with UI
- spawns safe sandboxes
- secure vault

Official docs: 
- https://github.com/BerriAI/litellm-agent-platform
- https://docs.litellm-agent-platform.ai/introduction

## Install instructions

Install agent-sandbox dependency

helm repo add agent-sandbox https://kubernetes-sigs.github.io/agent-sandbox
helm repo update
helm install agent-sandbox-controller agent-sandbox/agent-sandbox-controller

Deploy required components:
- postgres database
- LiteLLM gateway

--> Required env vars: https://docs.litellm-agent-platform.ai/installation#required-env-vars

Dashboard container (ignore db): https://github.com/BerriAI/litellm-agent-platform/blob/main/docker-compose.yml

K8s deployments? https://github.com/BerriAI/litellm-agent-platform/tree/main/k8s
