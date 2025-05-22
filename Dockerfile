FROM ubuntu:22.04

# labels
LABEL description="Base image for openresty and php"
LABEL app="phpfpm"
LABEL php_version="8.3.93"
LABEL php_mode="fpm"

# renovate: datasource=repology depName=ubuntu_24_04/php-fpm versioning=deb
ARG PHP_FPM_VERSION="2:8.3+93ubuntu2"
# renovate: datasource=repology depName=ubuntu_24_04/php-fpm versioning=loose
ARG PHP_MAJOR_MINOR_VERSION="8.3"

ENV PHP_MAJOR_MINOR_VERSION=${PHP_MAJOR_MINOR_VERSION}

LABEL php_fpm_version="${PHP_FPM_VERSION}"

USER root

# Copy entrypoint script
COPY scripts/entrypoint.sh /opt/pepe/
RUN chown www-data:www-data /opt/pepe/entrypoint.sh \
    && chmod 755 /opt/pepe/entrypoint.sh

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --no-install-suggests -y \
        php-fpm=$PHP_FPM_VERSION \
        php-mysqli \
        php-bcmath \
        php-exif \
        php-gd \
        php-opcache \
        php-zip \
        php-curl \
        php-xml \
        php-intl \
        php-redis \
        php-gmp \
        php-mbstring \
        php-imagick \
        rsync \
        unzip \
        curl \
	&& DEBIAN_FRONTEND=noninteractive apt-get clean \
    && DEBIAN_FRONTEND=noninteractive apt-get remove -y --purge \
        gnupg2 \
        lsb-release \
        software-properties-common \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /var/log/php8.3-fpm.log \
    && mkdir -p /usr/local/openresty/nginx/uwsgi_temp/ \
    && mkdir -p /usr/local/openresty/nginx/scgi_temp/ \
    && mkdir -p /usr/local/openresty/nginx/proxy_temp/ \
    && mkdir -p /usr/local/openresty/nginx/fastcgi_temp/ \
    && mkdir -p /usr/local/openresty/nginx/client_body_temp/ \
    && chown www-data:www-data /usr/local/openresty/nginx/*_temp
# Copy nginx configuration files
COPY conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy own php-fpm & modules configuration
RUN mkdir -p /var/run/php && \
	mkdir -p /var/log/php-fpm && \
    ln -sf /run/php/php${PHP_MAJOR_MINOR_VERSION}-fpm.sock /var/run/php-fpm.sock

COPY conf/phppepe.ini /etc/php/${PHP_MAJOR_MINOR_VERSION}/fpm/conf.d/20-phppepe.ini

USER www-data

EXPOSE 8081

# Minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

CMD ["/opt/pepe/entrypoint.sh"]

