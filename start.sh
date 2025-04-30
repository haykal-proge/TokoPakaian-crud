#!/bin/bash

# Jalankan PHP-FPM di background
php-fpm -D

# Jalankan Laravel migration
php artisan migrate --force

php artisan config:cache
php artisan route:cache
php artisan view:cache

# Jalankan nginx di foreground
nginx -g "daemon off;"
