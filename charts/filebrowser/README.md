# Filebrowser

Utility to upload files to a remote PVC.

docker run -d \
  --name filebrowser-test \
  -p 8080:80 \
  -v "$(pwd)/pvc-data:/srv" \
  filebrowser/filebrowser:latest


Default user: admin
Default password: set in logs

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pvc-uploader
spec:
  replicas: 1
  selector:
    matchLabels:
      app: pvc-uploader
  template:
    metadata:
      labels:
        app: pvc-uploader
    spec:
      containers:
        - name: filebrowser
          image: filebrowser/filebrowser:latest
          ports:
            - containerPort: 80
          volumeMounts:
            # Mount as many PVCs as you want under /srv
            - name: app-data-1
              mountPath: /srv/app-data-1
            - name: app-data-2
              mountPath: /srv/app-data-2
      volumes:
        - name: app-data-1
          persistentVolumeClaim:
            claimName: your-first-longhorn-pvc
        - name: app-data-2
          persistentVolumeClaim:
            claimName: your-second-longhorn-pvc
```