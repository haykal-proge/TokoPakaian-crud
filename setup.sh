#!/bin/bash

# Generate application key if not exists
if [ -z "$APP_KEY" ]; then
  php artisan key:generate
fi

# Continue with other setup commands
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force
