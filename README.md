<p align="center">
    <img src="https://img.shields.io/github/v/tag/vedatunlu/php-fpm-image">
    <img src="https://img.shields.io/github/repo-size/vedatunlu/php-fpm-image">
    <img src="https://img.shields.io/github/last-commit/vedatunlu/php-fpm-image">
    <img src="https://img.shields.io/github/release-date/vedatunlu/php-fpm-image">
    <img src="https://img.shields.io/badge/licence-MIT-green">
</p>

# PHP-FPM Docker Image

This package is a php-fpm image for php applications. You can call this image statically on your docker file and customize it according to
your application needs.

### 1. Create a new Dockerfile on the root of your project

Place the code below on top of your Dockerfile

```
  FROM ghcr.io/vedatunlu/php-fpm-image:latest
```

### 2. Add configs and copy your project to the container that will be created

Image has default configurations but you are free to use your own config files. Place your configuration files to your project. For example I placed my own configuration files inside "./deploy"
folder and copy your configuration files to the container that will be created after running Dockerfile.

```
  COPY ./deploy/php/php-fpm.ini /usr/local/etc/php/php-99.ini
  COPY ./deploy/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
  COPY ./deploy/nginx/nginx.conf /etc/nginx/nginx.conf
  COPY ./deploy/nginx/default.conf /etc/nginx/conf.d/
  COPY ./deploy/entrypoint.sh /entrypoint.sh
  
  COPY --chown=www-data:www-data . .

  RUN \
  composer install --no-cache && composer dump-autoload -o && composer clear-cache \
  \
  yarn install && yarn prod && yarn cache clean --all \
  \
  && chown -R www-data:www-data vendor/ composer.lock \
  && chmod -R 755 /var/www/storage && chmod -R 755 /var/www/bootstrap \
  && chmod +x /entrypoint.sh
```

### 2. Entrypoint

You can create a sh script file and add it to the entrypoint of the container if you have any command that has to run
after container created.

For example; create ./deploy/entrypoint.sh file to run necessary command and added it to at bottom of the Dockerfile

```
  ENTRYPOINT [ "/entrypoint.sh" ]
```

You are free to use your own configuration files (nginx, php.ini etc.).

### 3. Build image

```sh
  docker build -f ./Dockerfile -t [image-name] .
```

### 4. Run container

```sh
  docker run -it -p 8000:80 [image-name]
```

The command above will create a container mapping the port number to 8000.
You can now get response from http://localhost:8000


### Review of Docker file

```
FROM ghcr.io/vedatunlu/php-fpm-image:latest

COPY ./deploy/php/php-fpm.ini /usr/local/etc/php/php-99.ini
COPY ./deploy/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./deploy/nginx/nginx.conf /etc/nginx/nginx.conf
COPY ./deploy/nginx/default.conf /etc/nginx/conf.d/
COPY ./deploy/entrypoint.sh /entrypoint.sh

COPY --chown=www-data:www-data . .

RUN \
composer install --no-cache && composer dump-autoload -o && composer clear-cache \
\
yarn install && yarn prod && yarn cache clean --all \
\
&& chown -R www-data:www-data vendor/ composer.lock \
&& chmod -R 755 /var/www/storage && chmod -R 755 /var/www/bootstrap \
&& chmod +x /entrypoint.sh \
\
&& php artisan clear-compiled || : \
&& php artisan cache:clear || : \
&& php artisan config:clear || : \
&& php artisan event:clear || : \
&& php artisan optimize:clear || : \
&& php artisan route:clear || : \
&& php artisan view:clear || :

ENTRYPOINT [ "/entrypoint.sh" ]
```


# Contributing to the package

We welcome and appreciate your contributions to the package! The contribution guide can be
found [here](https://github.com/vedatunlu/php-fpm-image/blob/master/CONTRIBUTE.md).

## License

This package is open-sourced software licensed under
the [MIT license](https://github.com/vedatunlu/php-fpm-image/blob/master/LICENSE).
