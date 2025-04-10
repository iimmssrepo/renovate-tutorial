# base image
FROM alpine:3.11.3@sha256:ab00606a42621fb68f2ed6ad3c88be54397f981a7b70a79db3d1172b11c4367d as builder

# install dependencies
RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync \
    build-base \
    libc6-compat

# hugo version
# renovate: datasource=github-releases depName=gohugoio/hugo versioning=loose
ARG HUGO_VERSION="0.63.2"

RUN mkdir -p /usr/local/src && \
    cd /usr/local/src && \
    curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz | tar -xz && \
    mv hugo /usr/local/bin/hugo && \
    addgroup -Sg 1000 hugo && \
    adduser -Sg hugo -u 1000 -h /src hugo

# setup workdir
WORKDIR /src

# copy files
COPY . .

# build website
RUN hugo --ignoreCache


FROM openresty/openresty:1.27.1.2-rocky-amd64@sha256:4ddb68f51630858e7e83eaf1b7cac0a08a497ce93de0ebe43a472b67cfcc658d

USER root

WORKDIR /var/www/html/
COPY --from=builder /src/public/ ./

# setup permissions to folder and files
WORKDIR /var/www/html
RUN chown -R www-data:www-data . && \
        find . -type d -exec chmod 755 {} \; && \
        find . -type f -exec chmod 644 {} \;

USER www-data
EXPOSE 8081

# minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["openresty","-g", "daemon off;"]
