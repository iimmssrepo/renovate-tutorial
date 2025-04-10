# base image
FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c as builder

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
ARG HUGO_VERSION="0.145.0"

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
