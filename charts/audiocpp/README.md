# Audio.cpp

GGUF for speech models

https://github.com/0xShug0/audio.cpp/blob/main/docs/docker.md#usage

With WebUI:

```bash
docker run --rm \
  -p 8080:8080 \
  ghcr.io/0xshug0/audio.cpp:full-cpu \
  server --ui --ui-management --host 0.0.0.0 --port 8080 --backend cpu
```



Server API: https://github.com/0xShug0/audio.cpp/blob/main/app/server/README.md
