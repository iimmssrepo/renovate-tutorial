FROM ubuntu:24.04@sha256:72297848456d5d37d1262630108ab308d3e9ec7ed1c3286a32fe09856619a782 AS production

# labels
LABEL description="Base image for base images for products"
LABEL app="Only OS"
LABEL os="ubuntu"
LABEL os_version="24.04"
LABEL os_upgrade_date="20250204"

RUN apt-get update \
        && useradd -p '*' -c '' -s /bin/false sngular



HEALTHCHECK NONE
