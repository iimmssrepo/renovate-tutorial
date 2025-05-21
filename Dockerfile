
FROM ubuntu:24.04 AS production

# labels
LABEL mantainer="Cloud Devops Team"
LABEL description="Base image for java 8 runtime"
LABEL app="java 8"
LABEL java_version="8u452-ga~us1-0ubuntu1~24.04 amd64"

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-8 versioning=loose
ARG JAVA_JRE_VER="8u452-ga~us1-0ubuntu1~24.04"
# renovate: datasource=repology depName=ubuntu_24_04/ca-certificates-java versioning=loose
ARG JAVA_CA_CERTS_VER="20240118"

USER root

# Install OpenJDK-8
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-8-jre-headless=${JAVA_JRE_VER} \
    ca-certificates-java=${JAVA_CA_CERTS_VER} \
  && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjre-amd64/

RUN export JAVA_HOME

USER pepe

HEALTHCHECK NONE
