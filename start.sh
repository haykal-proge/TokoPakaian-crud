#!/bin/bash

echo "Starting deployment process..."

# Set correct permissions
chmod -R 755 .
chmod -R 777 storage bootstrap/cache

# Create .env file if doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    php artisan key:generate
fi

# Generate app key if not set
if [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate
fi

# Clear all caches
php artisan optimize:clear

# Create storage link
php artisan storage:link || true

# Run migrations
php artisan migrate --force

# Cache configurations
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Start the app
vendor/bin/heroku-php-nginx -C nginx_app.conf public/
