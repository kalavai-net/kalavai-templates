# Vector Observability Pipelines

This chart provides Vector configuration for collecting logs from Kubernetes workloads and forwarding them to ClickHouse.

## Overview

Vector is a high-performance, end-to-end observability data pipeline that collects, transforms, and routes logs, metrics, and traces. This configuration sets up Vector as an Agent (DaemonSet) on each Kubernetes node to collect stdout/stderr logs from all containers and send them to ClickHouse.

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Kubernetes     │     │  Vector Agent   │     │   ClickHouse    │
│  Workloads      │────▶│  (DaemonSet)    │────▶│   Database      │
│  (stdout/stderr)│     │  on each node   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

## Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.x
- ClickHouse instance (see ClickHouse setup section)

## Quick Start

### 1. Install ClickHouse

Install clickhouse or use ClickHouse Cloud

```bash
# Add ClickHouse Helm repository
helm repo add clickhouse https://charts.clickhouse.com/
helm repo update

# Install ClickHouse
helm install clickhouse clickhouse/clickhouse -n clickhouse --create-namespace
```

### 2. Install Vector

```bash
# Add Vector Helm repository
helm repo add vector https://helm.vector.dev
helm repo update
```

**Configure ClickHouse:**
Update thefield in `examples/helm-values.yaml` to match your ClickHouse instance:

```yaml
sinks:
  clickhouse:
    type: clickhouse
    inputs:
    - "reshape_for_clickhouse" # match the vector pipeline final input for clickhouse
    endpoint: "https://acmpvq21xs.europe-west2.gcp.clickhouse.cloud:8443" # match endpoint in Clickhouse > Service > connect
    database: logs
    table: events
    format: json_each_row
    compression: gzip
    batch:
      max_events: 1000
      timeout_secs: 10
    auth:
      strategy: basic
      user: default
      password: "<your_password_here>" # match the password of the Clickhouse service (go to All services > Service settings > Reset password)
```

# Install using values file (configuration in values file)
helm install vector vector/vector -n vector --values examples/helm-values.yaml --create-namespace -n vector
```

**Configuration Options:**

- **Option 1: Helm values at installation** - Use `--set` flags or `-f values.yaml` during install/upgrade
- **Option 2: ConfigMap** - Create a ConfigMap with Vector config and mount it (see `examples/vector-configmap.yaml`)
- **Option 3: Vector Operator** - Use Vector CRDs for dynamic configuration without helm upgrades
- **Option 4: Post-install upgrade** - Update configuration anytime with `helm upgrade`

### 3. Create ClickHouse Table

**Understanding Vector to ClickHouse Schema Mapping:**

Vector's ClickHouse sink sends data as JSON objects (by default using `json_each_row` format). ClickHouse automatically maps JSON fields to table columns by field name. Vector enriches logs with Kubernetes metadata (pod name, namespace, labels, etc.) which can be mapped to your table columns.

**How Vector adapts to your schema:**

1. **Field mapping:** Vector sends JSON with field names that must match your ClickHouse column names
2. **Format options:** 
   - `json_each_row` (default): Sends each log as a JSON object, ClickHouse auto-maps fields to columns
   - `arrow_stream`: Uses Arrow format with stricter type safety, requires schema fetch at startup
3. **Transforms:** Use Vector transforms to reshape/rename fields before sending to ClickHouse
4. **skip_unknown_fields:** Set to `true` to ignore JSON fields that don't have matching columns

**Example field mapping:**
```
Vector JSON output → ClickHouse column
.timestamp         → timestamp
.message           → message
.level             → level
.kubernetes.pod_name → pod_name
.kubernetes.namespace_name → namespace
.kubernetes.container_name → container_name
.kubernetes.node_name → node_name
.kubernetes.pod_labels.app → app
.kubernetes.pod_labels.env → env
.user_id           → user_id
.model_id          → model_id
.event_id          → event_id
.vram_usage        → vram_usage
.memory_usage      → memory_usage
.cpu_usage         → cpu_usage
.gpu_type          → gpu_type
.interval_seconds  → interval_seconds
.gpu_provider      → gpu_provider
```

Create the ClickHouse table:

```bash
# Connect to ClickHouse
kubectl exec -it -n clickhouse clickhouse-0 -- clickhouse-client

# Run the setup script
kubectl exec -n clickhouse clickhouse-0 -- clickhouse-client --multiquery < examples/clickhouse-setup.sql
```


### 4. Verify Installation

```bash
# Check Vector pods
kubectl get pods -n vector

# Check Vector logs
kubectl logs -n vector daemonset/vector

# Verify logs in ClickHouse
kubectl exec -it -n clickhouse clickhouse-0 -- clickhouse-client --query "SELECT * FROM logs.events LIMIT 10"
```

## Configuration

### Vector Source Configuration

**How Vector transforms JSON stdout logs into structured events:**

1. **Raw stdout output:** Your application prints JSON to stdout (e.g., `{"timestamp":"2024-01-15T10:30:00.123Z","level":"INFO","message":"Application running","user_id":12345}`)
2. **Kubernetes captures logs:** Kubernetes container runtime writes stdout/stderr to log files on the node (typically `/var/log/containers/*.log`)
3. **Vector reads log files:** Vector's `kubernetes_logs` source tails these log files from the node's filesystem
4. **Vector parses and enriches with metadata:** Vector automatically adds Kubernetes context to each log line, creating a structured event
5. **Structured event output:** The enriched event is passed through transforms and sent to ClickHouse

**Example transformation:**

```
Raw stdout from your app:
  {"timestamp":"2024-01-15T10:30:00.123Z","level":"INFO","message":"Application running normally","user_id":12345,"request_id":"abc-123"}

Vector's kubernetes_logs source reads and enriches it:
  {
    "timestamp": "2024-01-15T10:30:00.123Z",
    "message": "{\"timestamp\":\"2024-01-15T10:30:00.123Z\",\"level\":\"INFO\",\"message\":\"Application running normally\",\"user_id\":12345,\"request_id\":\"abc-123\"}",
    "kubernetes": {
      "pod_name": "log-generator-7d8f9c5b4-k2m4p",
      "namespace_name": "default",
      "container_name": "log-generator",
      "node_name": "node-1",
      "pod_labels": {
        "app": "log-generator",
        "env": "production"
      }
    },
    "stream": "stdout"
  }

After parse_json and reshape transforms:
  {
    "timestamp": "2024-01-15T10:30:00.123Z",
    "message": "Application running normally",
    "level": "INFO",
    "user_id": 12345,
    "request_id": "abc-123",
    "pod_name": "log-generator-7d8f9c5b4-k2m4p",
    "namespace": "default",
    "container_name": "log-generator",
    "node_name": "node-1",
    "app": "log-generator",
    "env": "production"
  }

Sent to ClickHouse as JSON (json_each_row format):
  {"timestamp":"2024-01-15T10:30:00.123Z","message":"...","level":"INFO","user_id":12345,"request_id":"abc-123","pod_name":"...","namespace":"default",...}
```

**Filtering workloads by labels:**

The `kubernetes_logs` source provides three selector options to filter which pods/namespaces to collect logs from:

```yaml
sources:
  kubernetes_logs:
    type: kubernetes_logs
    # Filter by pod labels (Kubernetes label selector syntax)
    extra_label_selector: "app in (my-app,another-app),environment!=test"
    # Filter by namespace labels
    extra_namespace_label_selector: "monitoring=true"
    # Filter by pod fields (Kubernetes field selector syntax)
    extra_field_selector: "status.phase=Running"
    auto_partial_merge: true
    data_dir: /var/lib/vector
```

**Label selector examples:**
- `"app=my-app"` - Only pods with label `app=my-app`
- `"app in (app1,app2)"` - Pods with `app=app1` OR `app=app2`
- `"app"` - Pods that have the `app` label (any value)
- `"!app"` - Pods that do NOT have the `app` label
- `"app!=vector"` - Exclude pods with label `app=vector`
- `"environment=production,team=backend"` - Pods with both labels
- `"environment!=test"` - Exclude pods with `environment=test`

**Namespace label selector examples:**
- `"monitoring=true"` - Only namespaces with label `monitoring=true`
- `"environment in (production,staging)"` - Production or staging namespaces
- `"name!=kube-system"` - Exclude kube-system namespace

**Field selector examples:**
- `"status.phase=Running"` - Only running pods
- `"spec.restartPolicy=Always"` - Pods with Always restart policy
- `"metadata.name!=excluded-pod"` - Exclude specific pod by name


### Filter Configuration

**Filter logs by content:**

You can filter logs based on their content using Vector transforms after collection:

```yaml
transforms:
  # Check if message is valid JSON before parsing
  check_json:
    type: remap
    inputs: ["kubernetes_logs"]
    source: |
      .is_json, err = parse_json(.message)
      if err == null {
        . = merge(., .is_json)
        del(.is_json)
      } else {
        # Drop non-JSON logs
        abort()
      }

  # Then parse and reshape
  parse_json:
    type: remap
    inputs: ["check_json"]
    source: |
      .parsed, err = parse_json(.message)
      if err != null {
        .parsed = {"message": .message, "level": "INFO"}
      }
      . = merge(., .parsed)
      del(.parsed)
```

### Vector Sink Configuration

ClickHouse sink configuration with batching and buffering for JSON logs:

```yaml
sinks:
  clickhouse:
    type: clickhouse
    inputs: ["kubernetes_logs"]
    endpoint: http://clickhouse.clickhouse.svc.cluster.local:8123
    database: logs
    table: events
    format: json_each_row
    compression: gzip
    batch:
      max_events: 1000
      timeout_secs: 10
    buffer:
      type: disk
      max_events: 10000
    skip_unknown_fields: true
```

## Batching and Aggregation

### Batching Configuration

Control when data is flushed to ClickHouse:

```yaml
batch:
  max_events: 1000      # Maximum events per batch
  max_bytes: 10485760   # Maximum bytes per batch (10MB)
  timeout_secs: 10      # Flush after 10 seconds regardless of size
```

Batches are flushed when **either** condition is met:
- Batch size reaches `max_events` or `max_bytes`
- Batch age reaches `timeout_secs`

### Aggregator vs Agent

For most use cases, you only need Vector Agent (DaemonSet) collecting logs locally and sending directly to ClickHouse. Use a separate Vector Aggregator if you need:
- Centralized transformation across all logs
- PII scrubbing
- Complex filtering
- Routing to multiple destinations

See `examples/vector-aggregator.yaml` for aggregator configuration.

## Examples

This chart includes example configurations:

- `examples/log-generator-json.yaml` - Example workload that outputs JSON logs to stdout
- `examples/clickhouse-setup.sql` - ClickHouse table setup for JSON logs
- `examples/helm-values.yaml` - Helm values with all options

## Documentation

- [Vector Documentation](https://vector.dev/docs/introduction/)
- [Vector on Kubernetes](https://vector.dev/docs/setup/installation/platforms/kubernetes/)
- [ClickHouse Sink](https://vector.dev/docs/reference/configuration/sinks/clickhouse/)
- [Kubernetes Logs Source](https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/)

