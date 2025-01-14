# Use an sngular ubuntu base as a parent image
FROM ubuntu@sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab

LABEL python_version="3.11"

# Disable Prompt During Package Installation
ARG DEBIAN_FRONTEND=noninteractive

ARG PYTHON_VERSION=3.11

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
