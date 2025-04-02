FROM ubuntu:24.04@sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab AS production

# labels
LABEL mantainer="Iñigo Montesino Vilches"
LABEL description="Base image for base images for products"
LABEL app="Only OS"
LABEL company="sngular"
LABEL os="ubuntu"
LABEL os_version="24.04"
LABEL os_upgrade_date="20250204"

RUN apt-get update \
        && useradd -p '*' -c '' -s /bin/false sngular

# use sngular user
USER sngular

HEALTHCHECK NONE
