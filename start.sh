#!/bin/bash

# Set correct permissions
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Generate app key if not exists
php artisan key:generate --no-interaction --force

# Run migrations
php artisan migrate --force

# Start PHP-FPM
php-fpm -D

# Start Nginx
nginx -g "daemon off;"
