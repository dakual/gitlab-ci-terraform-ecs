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

RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

RUN apk add --no-cache procps

WORKDIR /app

COPY public/ /app/public
COPY src/ /app/src

COPY --from=vendor /tmp/vendor/ /app/vendor/

CMD [ "php", "-S", "0.0.0.0:5000", "-t", "public/", "-c", "php.ini" ]