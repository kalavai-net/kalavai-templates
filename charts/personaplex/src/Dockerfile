FROM python:3.12-slim

RUN apt update && apt install -y git libopus-dev build-essential gcc g++

WORKDIR /app

RUN git clone https://huggingface.co/brianmatzelle/personaplex-7b-v1-bnb-4bit && \
    cd personaplex-7b-v1-bnb-4bit && \
    pip install moshi/.

COPY requirements.txt .
RUN pip install -r requirements.txt

