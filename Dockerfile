# Use an sngular ubuntu base as a parent image
FROM ubuntu:24.04 AS production

# labels
LABEL description="Base image for Python-based products"
LABEL app="python"
LABEL python_version="3.10"

# Disable Prompt During Package Installation
ARG DEBIAN_FRONTEND=noninteractive

# renovate: datasource=repology depName=ubuntu_24_04/python versioning=loose
ARG PYTHON_VERSION=3.10

USER root

RUN apt-get update \
      && apt-get install --no-install-recommends -y \
         python${PYTHON_VERSION} \
         python${PYTHON_VERSION}-dev \
         python${PYTHON_VERSION}-venv \
         python3-pip python3-wheel python-is-python3 \
         build-essential \
      && apt-get clean \
      && rm -fr /var/lib/apt/lists/apt /var/lib/apt/lists/dpkg \
            /var/lib/apt/lists/cache /var/lib/apt/lists/log /tmp/* /var/tmp/* \
      && rm /usr/bin/python3 \
      && ln -s python${PYTHON_VERSION} /usr/bin/python3


