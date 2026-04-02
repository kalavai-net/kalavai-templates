FROM python:3.12-slim

RUN apt update --yes && \
    apt install --yes --no-install-recommends \
    # Common useful utilities
    build-essential \
    wget \
    curl \
    git \
    nano-tiny \
    tzdata \
    unzip \
    vim-tiny \
    # git-over-ssh
    openssh-client \
    # `less` is needed to run help in R
    # see: https://github.com/jupyter/docker-stacks/issues/1588
    less \
    # `nbconvert` dependencies
    # https://nbconvert.readthedocs.io/en/latest/install.html#installing-tex
    texlive-xetex \
    texlive-fonts-recommended \
    texlive-plain-generic \
    # Enable clipboard on Linux host systems
    xclip && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Install miniconda
ENV CONDA_DIR=/opt/conda
SHELL ["/bin/bash", "-c"]
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda
# Put conda in path so we can use conda activate

# install jupyterhub to match helm version in the cluster
RUN pip install --no-cache-dir jupyterhub==5.4.3 jupyterlab

# Create kalavai user with proper home directory (this is the standard JupyterHub username)
RUN useradd -m -s /bin/bash kalavai && \
    chown -R kalavai:kalavai /opt/conda && \
    mkdir -p /home/kalavai/.local && \
    chown -R kalavai:kalavai /home/kalavai

USER kalavai
WORKDIR /home/kalavai

# Set environment variables for the container session
ENV PATH=$CONDA_DIR/bin:$PATH
ENV SHELL=/bin/bash

# Initialize bashrc for interactive sessions
RUN conda init bash && \
    echo "source /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc

# set the default command of the image,
# if you want to launch more complex startup than the default `juptyerhub-singleuser`.
# To launch an image's custom CMD instead of the default `jupyterhub-singleuser`
# set `singleuser.cmd: null` in your config.yaml.
CMD ["jupyterhub-singleuser"]