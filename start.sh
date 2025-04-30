#!/bin/bash

# Set correct permissions
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Ensure .env exists and has required variables
if [ ! -f .env ]; then
    cp .env.example .env
fi

# Generate app key if not exists
if ! grep -q "^APP_KEY=" .env || [ "$(grep '^APP_KEY=' .env | cut -d '=' -f2)" == "" ]; then
    php artisan key:generate --no-interaction --force
fi

# Run migrations
php artisan migrate --force

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"
