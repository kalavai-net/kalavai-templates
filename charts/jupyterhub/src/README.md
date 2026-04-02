# Custom images for jupyterhub

https://z2jh.jupyter.org/en/stable/repo2docker.html
https://z2jh.jupyter.org/en/stable/jupyterhub/customizing/user-environment.html#customize-an-existing-docker-image

Must have the jupyterhub package installed to match the deployment chart version


## Build

docker build -t ghcr.io/kalavai-net/jupyterhub-cpu:latest .
docker push ghcr.io/kalavai-net/jupyterhub-cpu:latest