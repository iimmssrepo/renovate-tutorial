# Node
FROM node:18 AS node

# install specific npm
RUN npm i npm@9.6.7 -g

# install dependencies from package.json file
WORKDIR /opt/package
COPY ./package*.json ./
COPY ./esbuild*.mjs ./
COPY ./assets ./assets/

RUN npm install --no-optional --legacy-peer-deps

# build
RUN npm run build

# composer build
FROM composer:2.4.4 AS composer

# install dependencies from composer.json
WORKDIR /opt/composer/
COPY ./composer.* ./
COPY ./bin ./bin/
COPY ./src ./src/
COPY ./config ./config/
COPY ./.env ./.env

RUN mkdir -p /opt/composer/public
RUN composer install --ignore-platform-reqs

FROM keglin/pinchflat:v2025.1.17

RUN export APP_ENV='${APP_ENV}' && \
	export APP_SECRET='${APP_SECRET}' && \
	export TRUSTED_HOSTS='${TRUSTED_HOSTS}' && \
	export BUILD='${BUILD}' && \
	export DATABASE_URL='${DATABASE_URL}' && \
	export SNGWEB_STORAGE_BUCKET='${SNGWEB_STORAGE_BUCKET}' && \
	export SNGWEB_STORAGE_CDN='${SNGWEB_STORAGE_CDN}' && \
	export REDIS_PORT='${REDIS_PORT}' && \
	export REDIS_HOST='${REDIS_HOST}' && \
	export REDIS_PASSWORD='${REDIS_PASSWORD}' && \
	export LOCK_DSN='${LOCK_DSN}'

USER root

RUN apt-get update && \
	apt-get install --no-install-recommends --no-install-suggests -y \
	&& rm -rf /var/lib/apt/lists/*

# Setup permissions to folder and files
RUN chown -R www-data:www-data /var/www/html && chown -R www-data:www-data /run/php/ \
	&& find . -type d -exec chmod 755 {} \; \
	&& find . -type f -exec chmod 644 {} \;

USER www-data

# Copy own pepito code
WORKDIR /var/www/html/

RUN mkdir -p var/cache/dev
RUN mkdir -p var/log

COPY ./containerconf/20-phppepito.ini /etc/php/8.1/fpm/conf.d/20-phppepito.ini
COPY ./bin ./bin/
COPY ./config ./config/
COPY ./src ./src/
COPY ./templates ./templates/
COPY ./translations ./translations/
COPY ./.env ./.env
COPY ./composer.json ./
COPY --from=node --chown=www-data:www-data /opt/package/public/ ./public/
COPY --from=composer --chown=www-data:www-data /opt/composer/vendor/ ./vendor/
COPY --from=composer --chown=www-data:www-data /opt/composer/public/ ./public/
COPY --chown=www-data:www-data ./public/index.php ./public/
COPY ./containerconf/www.conf /etc/php/8.1/fpm/pool.d/www.conf
COPY ./containerconf/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY ./containerconf/entrypoint.sh /opt/pepito/entrypoint.sh

EXPOSE 8081

# Minimal healthcheck
HEALTHCHECK --interval=5m --timeout=3s CMD curl --fail http://localhost:8081/ || exit 1

CMD ["/opt/pepito/entrypoint.sh"]

