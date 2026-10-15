# extend base langflow image with dependencies  (bundles)
# https://docs.langflow.org/extensions-bundle-list#additional-bundles
ARG LANGFLOW_VERSION=1.12.6

FROM langflowai/langflow:${LANGFLOW_VERSION}

RUN uv pip install "langflow[bundles]"

CMD ["langflow", "run"]