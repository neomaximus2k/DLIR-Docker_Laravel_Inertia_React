FROM php:8.3-fpm-alpine
# check the latest supported version and update above 
# https://www.php.net/supported-versions.php

# Install system dependencies
RUN apk add --no-cache --update git curl libpng libpng-dev libjpeg-turbo-dev \
    libwebp-dev zlib-dev libxpm-dev gd-dev zip libzip-dev supervisor \
    nodejs npm \
    && docker-php-ext-install pdo pdo_mysql gd zip exif pcntl

# Get latest Composer from coposer public docker image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Setup laravel crons
COPY ./AppDockerFiles/Laravel.cron /etc/cron.d/laravel-cron
RUN chmod 0644 /etc/cron.d/laravel-cron \
    && crontab /etc/cron.d/laravel-cron \
    && mkdir /var/log/cron

# Expose port 9000 and start php-fpm server
EXPOSE 9000

COPY --chmod=0775 ./AppDockerFiles/Entrypoint.sh /usr/local/bin/entrypoint.sh
    
CMD ["sh", "/usr/local/bin/entrypoint.sh"]