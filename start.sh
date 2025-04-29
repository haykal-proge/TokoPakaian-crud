#!/bin/bash

# Jalankan PHP-FPM di background
php-fpm -D

# Jalankan Laravel migration
php artisan migrate --force

# Jalankan nginx di foreground
nginx -g "daemon off;"
