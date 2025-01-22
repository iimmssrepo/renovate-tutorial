FROM ubuntu:noble

# labels
LABEL description="Base image for openresty with Java 11 runtime"
LABEL app="openresty with java 11 service."

# renovate: datasource=repology depName=ubuntu_24_04/openjdk-lts versioning=deb
ARG JAVA_VERSION="11.0.21+9-0ubuntu1~22.04"
# renovate: datasource=repology depName=ubuntu_24_04/ca-certificates-java versioning=deb
ARG JAVA_CA_CERTS_VERSION="20190909ubuntu1.2"

ARG JAVA_JRE_VER="${JAVA_VERSION}"
ARG JAVA_CA_CERTS_VER="${JAVA_CA_CERTS_VERSION}"

LABEL java_version="${JAVA_VERSION}"

LABEL java_version="${JAVA_VERSION}"

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/

USER root

# Install OpenJDK-11
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-11-jre-headless=${JAVA_JRE_VERSION} \
    ca-certificates-java=${JAVA_CA_CERTS_VERSION} \
  && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && export JAVA_HOME

# Copy configuration files
COPY --chown=www-data:www-data conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

USER www-data

EXPOSE 8081

# Minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

CMD ["openresty","-g", "daemon off;"]


