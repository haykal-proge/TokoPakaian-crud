#!/bin/bash

# Start PHP-FPM in background
php-fpm -D

# Migrate DB jika belum
php artisan migrate --force || true

# Jalankan nginx
nginx -g "daemon off;"
