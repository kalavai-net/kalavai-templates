# Hermes agent

## Remote gateway setup

As the container command:

This is what the template deploys

## Local hermes desktop app

Install with:

```bash
# Set blank config.
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
# Run app:
hermes desktop
```

Then [connect to the remote gateway](https://hermes-agent.nousresearch.com/docs/user-guide/desktop#in-the-app) with Settings → Gateways → Remote gateway.

--> Honcho for memory card (extension to local memory .md)


Configure endpoint. Edit config.yaml in Settings (YAML view)

```yaml
model:
  provider: custom
  default: unsloth/Qwen3.5-0.8B-GGUF
  base_url: http://llm-llamacpp-service.default:8080/v1
custom_providers:
  - name: kalavai
    base_url: http://llm-llamacpp-service.default:8080/v1
    model: unsloth/Qwen3.5-0.8B-GGUF
    models:
      unsloth/Qwen3.5-0.8B-GGUF:
        context_length: 64000
```

# OpenAgent

https://github.com/the-open-agent/openagent

git clone https://github.com/the-open-agent/openagent
cd openagent
docker compose up

Available at: http://localhost:14000. Default username "admin", password "123"


