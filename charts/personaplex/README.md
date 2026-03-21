# Mimi Tokenizer Examples

This directory contains examples for using the kyutai/mimi tokenizer to convert audio streams to tokens and measure performance.

## Files

- `connect_to_moshi.py` - Original example connecting to remote Moshi server
- `mimi_tokenizer_example.py` - **NEW**: Comprehensive tokenizer benchmark and streaming demo

## Quick Start

```bash
# Install dependencies
pip install -r requirements.txt

# Run the tokenizer examples
python mimi_tokenizer_example.py
```

## What the New Example Does

The `mimi_tokenizer_example.py` script provides three modes:

### 1. Token Counting Benchmark
- Records audio for a specified duration
- Converts audio to tokens using Mimi
- Calculates tokens per second in real-time
- Shows compression ratios and performance metrics

### 2. Streaming Tokenization Demo  
- Real-time tokenization of live audio
- Shows encoding latency
- Demonstrates streaming mode usage
- Displays buffer status

### 3. Quick Test
- 5-second version of the benchmark for quick validation

## Key Features

- **Real-time Statistics**: Shows current and average tokens/second
- **Performance Metrics**: Encoding latency, compression ratios
- **Streaming Mode**: Uses Mimi's streaming API for better performance
- **Audio Buffering**: Smooth processing with configurable buffer size
- **Error Handling**: Graceful handling of audio device issues

## Example Output

```
🎵 Mimi Tokenizer Examples
========================================
1. Token counting benchmark (30 seconds)
2. Streaming tokenization demo
3. Quick test (5 seconds)

Select option (1-3): 1

🎯 Starting Mimi tokenizer benchmark for 30 seconds...
🎤 Speak into your microphone to generate tokens
📊 Real-time token statistics will be displayed below
⏹️  Press Ctrl+C to stop early

Loading Mimi model...
Model loaded successfully!
🎙️  Audio stream started - begin speaking now!
📊 Stats: 150 tokens | Avg: 12.5 t/s | Current: 15.2 t/s | Time: 12.0s

📈 Final Results:
   Total tokens: 375
   Duration: 30.00 seconds
   Average tokens/second: 12.50
   Audio processed: 720000 samples
   Audio duration: 30.00 seconds
   Compression ratio: 384.00:1
```

## Technical Details

- **Sample Rate**: 24kHz (Mimi standard)
- **Frame Size**: 1920 samples (80ms at 24kHz)
- **Token Shape**: [1, 8, 1] - 8 codebooks, 1 timestep
- **Model**: kyutai/mimi from HuggingFace
- **Backend**: PyTorch with streaming support

## Requirements

- Python 3.8+
- PyTorch
- Transformers
- SoundDevice (for audio I/O)
- NumPy

See `requirements.txt` for exact versions.

---

# NVIDIA Personaplex (Legacy)

https://github.com/NVIDIA/personaplex

Quantized version: https://huggingface.co/brianmatzelle/personaplex-7b-v1-bnb-4bit

git clone https://huggingface.co/brianmatzelle/personaplex-7b-v1-bnb-4bit
cd personaplex-7b-v1-bnb-4bit
pip install moshi/.
pip install bitsandbytes
python -m moshi.server --quantize-4bit --host 0.0.0.0 --port 8998
(optionally pass --moshi-weight model_bnb_4bit.pt to avoid downloading full model)

For testing locally, access the node:

```bash
ssh -L 8998:localhost:8998 ubuntu@<node_ip>
```

Then:

```bash
python -m moshi.server --quantize-4bit --host 127.0.0.1 --port 8998
```

For production, use a service + ingress to be able to access the server with the browser


```yaml
apiVersion: v1
kind: Service
metadata:
  name: moshi-service
spec:
  selector:
    app: personaplex
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8998
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: moshi-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/proxy-body-size: "0" # Crucial for audio streaming
spec:
  tls:
  - hosts:
    - personaplex.kalavai.net
    secretName: moshi-tls-certs
  rules:
  - host: personaplex.kalavai.net
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: moshi-service
            port:
              number: 80
```

## Alternative (moshi)

python -m venv env
source env/bin/activate
pip install -r requirements.txt

python -m moshi.server --hf-repo kyutai/moshika-pytorch-bf16 --host 0.0.0.0 --gradio-tunnel

## Interact

### CLI

python -m moshi.client --url http://<address>:8998

### Python Script

python connect_to_moshi.py



