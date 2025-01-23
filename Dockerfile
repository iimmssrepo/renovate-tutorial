FROM ubuntu:noble

# labels
LABEL description="Base image for nodejs based products"
LABEL app="nodejs and npm engine"

# renovate: datasource=node depName=node versioning=node
ARG NODE_VERSION="22"
ARG NODE_ENV=development

LABEL node_version="${NODE_VERSION}"

USER root

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y \
        --no-install-recommends --no-install-suggests install \
        curl \
        gnupg \
    && curl -sL https://deb.nodesource.com/setup_"${NODE_VERSION}".x | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get -y update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install nodejs \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y
RUN npm install pm2 -g

# Add additional binaries into PATH for convenience
ENV NODE_ENV $NODE_ENV
ENV PATH="$PATH:/opt/node_app/node_modules/.bin"

# define workspace dir
WORKDIR /opt/node_app

RUN chown -R www-data:www-data /opt/node_app
RUN find . -type d -exec chmod 755 {} \;
RUN find . -type f -exec chmod 644 {} \;

USER www-data

EXPOSE 8081

# Minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

CMD ["openresty","-g", "daemon off;"]
