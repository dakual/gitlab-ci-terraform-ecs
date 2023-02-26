FROM composer:1.9.3 as vendor

WORKDIR /tmp/

COPY composer.json composer.json

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist

FROM php:7.4-cli-alpine

WORKDIR /app

COPY public/ /app/public
COPY src/ /app/src

COPY --from=vendor /tmp/vendor/ /app/vendor/

CMD [ "php", "-S", "0.0.0.0:80", "-t", "public/" ]