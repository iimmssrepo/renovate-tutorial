FROM ubuntu@sha256:80dd3c3b9c6cecb9f1667e9290b3bc61b78c2678c02cbdae5f0fea92cc6734ab

#labels
LABEL description="Base image for openresty based products"
LABEL app="openresty server"
LABEL openresty_version.label="1.25.3.2"

# # resty_deb_flavor build argument is used to select other
# # OpenResty Debian package variants.
# # For example: "-debug" or "-valgrind"
ARG resty_deb_flavor=""
# renovate: release=noble depName=openresty versioning=loose
ARG resty_deb_version="1.25.3.2-1~noble1"
ARG resty_image_base="ubuntu"
ARG resty_image_tag="noble"

# Dependencies versions
LABEL resty_image_base.label="${resty_image_base}"
LABEL resty_image_tag.label="${resty_image_tag}"
LABEL resty_deb_flavor.label="${resty_deb_flavor}"
LABEL resty_deb_version.label="${resty_deb_version}"

# Add additional binaries into PATH for convenience
ENV PATH="$PATH:/usr/local/openresty${resty_deb_flavor}/luajit/bin:/usr/local/openresty${resty_deb_flavor}/nginx/sbin:/usr/local/openresty${resty_deb_flavor}/bin"

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext-base \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -qO /tmp/pubkey.gpg https://openresty.org/package/pubkey.gpg \
  && gpg --dearmor -o /usr/share/keyrings/openresty.gpg < /tmp/pubkey.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/openresty.list > /dev/null \
  && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge \
    gnupg2 \
    lsb-release \
    software-properties-common \
    wget \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openresty${resty_deb_flavor}=${resty_deb_version} \
  && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
  && ln -sf /dev/stdout /usr/local/openresty${resty_deb_flavor}/nginx/logs/access.log \
  && ln -sf /dev/stderr /usr/local/openresty${resty_deb_flavor}/nginx/logs/error.log \
  && rm -rf /var/lib/apt/lists/* /tmp/pubkey.gpg /var/log/*log

# Copy nginx configuration files
COPY --chown=www-data:www-data conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY --chown=www-data:www-data conf/nginx.vh.default.conf /etc/nginx/conf.d/default.conf

# Copy default minimal page and files
COPY --chown=www-data:www-data resources/* /var/www/html/

WORKDIR /var/www/html
# setup permissions to folder and files
RUN find . -type d -exec chmod 755 {} \; \
  && find . -type f -exec chmod 644 {} \;

USER www-data

EXPOSE 8081

# Minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

CMD [ "/usr/bin/openresty", "-g", "daemon off;" ]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT
