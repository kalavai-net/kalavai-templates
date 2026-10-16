# extend base langflow image with dependencies  (bundles)
# https://docs.langflow.org/extensions-bundle-list#additional-bundles
ARG LANGFLOW_VERSION=1.12.6

FROM langflowai/langflow:${LANGFLOW_VERSION}

WORKDIR /app

RUN uv pip install "langflow[bundles]"

EXPOSE 7860
CMD ["python", "-m", "langflow", "run", "--host", "0.0.0.0", "--port", "7860"]