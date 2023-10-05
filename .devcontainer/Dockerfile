FROM ubuntu:latest

ARG NODE_VERSION=18.17.1
ARG NVM_VERSION=0.39.5
ARG DUCKDB_ASYNC_VERSION=0.8.1
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"


# Install System dependencies
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install \
        software-properties-common \
        curl \
        bash \
        python3-pip \
        python3.10-venv \     
        git \
        jq \
        make \
        unzip \
        unrar \
        make

WORKDIR /home

RUN apt install -y curl \
    && curl -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash

RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION} \
    && . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}

RUN npm i duckdb-async@${DUCKDB_ASYNC_VERSION}

# Install the dependencies file to the working directory
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install -r requirements.txt