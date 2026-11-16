# Langfuse

LLM tracing and monitoring platform.


worker -> docker.langfuse.com/langfuse/langfuse-worker:${LANGFUSE_IMAGE_TAG:-4}
web -> docker.langfuse.com/langfuse/langfuse:${LANGFUSE_IMAGE_TAG:-4}
ai-gateway -> docker.langfuse.com/langfuse/ai-gateway:${LANGFUSE_AI_GATEWAY_IMAGE_TAG:-${LANGFUSE_IMAGE_TAG:-4}}
clickhouse -> docker.io/clickhouse/clickhouse-server:26.3.62.3
minio -> cgr.dev/chainguard/minio
redis -> docker.io/redis:7
postgres -> docker.io/postgres:${POSTGRES_VERSION:-17}
