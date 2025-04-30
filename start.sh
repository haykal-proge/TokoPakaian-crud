#!/bin/bash
set -e

echo "========== Starting Laravel Deployment =========="

# Set correct permissions
echo "Setting permissions..."
chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Use Railway specific env if available
if [ -f .env.railway ]; then
    echo "Using Railway environment configuration..."
    cp .env.railway .env
elif [ ! -f .env ]; then
    echo "No .env found, copying from example..."
    cp .env.example .env
fi

# Ensure APP_KEY exists
echo "Checking APP_KEY..."
if ! grep -q "^APP_KEY=" .env || [ "$(grep '^APP_KEY=' .env | cut -d '=' -f2)" == "" ]; then
    echo "Generating application key..."
    php artisan key:generate --no-interaction --force
fi

# Set production environment in .env
echo "Setting production environment..."
sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
sed -i "s/APP_DEBUG=.*/APP_DEBUG=true/" .env  # Temporarily set to true for debugging

# Clear caches
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan view:clear
php artisan route:clear

# Create storage link
echo "Creating storage link..."
php artisan storage:link || true

# Run migrations if DB is configured
if grep -q "^DB_CONNECTION=" .env && [ "$(grep '^DB_CONNECTION=' .env | cut -d '=' -f2)" != "" ]; then
    echo "Running database migrations..."
    php artisan migrate --force
else
    echo "Skipping migrations - database not configured"
fi

# Verify PHP and Nginx configs
echo "Verifying configurations..."
php -v
php-fpm -t
nginx -t

# Start PHP-FPM with debugging
echo "Starting PHP-FPM..."
php-fpm -D

# Start Nginx in foreground with debug level
echo "Starting Nginx..."
echo "========== Deployment Complete =========="
echo "Application should be accessible at port 8080"
nginx -g "daemon off; error_log /dev/stderr debug;"
