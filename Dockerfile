FROM php:8.2-fpm as php

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /var/www
RUN rm -rf /var/www/*

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN \
    apt-get clean autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    \
    && apt-get update -y \
    \
    && chmod +x /usr/local/bin/install-php-extensions && sync \
    \
    && apt-get install -y \
        procps \
        iputils-ping \
        telnet \
        openssl \
        libcurl4-gnutls-dev \
        nginx \
        build-essential \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libonig-dev \
        zip unzip \
        jpegoptim optipng pngquant gifsicle \
        vim \
        git \
        curl \
        nano \
        gnupg \
        libssl-dev \
        apt-utils \
        libsodium-dev  \
        gosu \
        ca-certificates \
        supervisor \
        sqlite3 \
        libcap2-bin \
        nodejs npm \
        default-mysql-client \
    \
    && apt-get install -y imagemagick libmagickwand-dev libmagickcore-dev \
    \
    && apt-get -y install libzip-dev zip unzip && docker-php-ext-configure zip && docker-php-ext-install zip \
    \
    && apt-get install -y libcurl3-dev curl && docker-php-ext-install curl \
    \
    && apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && docker-php-ext-install gd \
    \
    && apt-get install -y locales && locale-gen tr_TR.UTF-8 && dpkg-reconfigure locales \
    \
    && apt-get install -y zlib1g-dev libicu-dev g++ && docker-php-ext-configure intl && docker-php-ext-install intl \
    \
    && install-php-extensions exif pcntl \
    \
    && docker-php-ext-install bcmath \
    \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && apt-get update -y && apt-get install -y yarn \
    \
    && docker-php-ext-install pdo mysqli pdo_mysql && docker-php-ext-enable pdo_mysql \
    && apt-get install -y libpq-dev && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-install pdo_pgsql pgsql \
    \
    && apt-get clean autoclean && apt-get -y autoremove && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY ./src/php-fpm/php-fpm.ini /usr/local/etc/php/php-99.ini
COPY ./src/php-fpm/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./src/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./src/nginx/default.conf /etc/nginx/conf.d/

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
