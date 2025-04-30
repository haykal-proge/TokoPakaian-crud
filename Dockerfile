FROM php:8.2-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev \
    zip unzip curl git nginx supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Ensure .env exists
COPY .env.example .env

# Set needed directories and permissions
RUN mkdir -p /run/php \
    && mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache \
    && chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /run/php \
    && chmod -R 775 storage bootstrap/cache

# Copy PHP-FPM configuration
COPY www.conf /usr/local/etc/php-fpm.d/www.conf

# Update PHP configuration
RUN echo "display_errors = Off" > /usr/local/etc/php/conf.d/error-logging.ini \
    && echo "log_errors = On" >> /usr/local/etc/php/conf.d/error-logging.ini \
    && echo "error_log = /dev/stderr" >> /usr/local/etc/php/conf.d/error-logging.ini \
    && echo "memory_limit = 256M" > /usr/local/etc/php/conf.d/memory-limit.ini \
    && echo "upload_max_filesize = 100M" > /usr/local/etc/php/conf.d/upload-limit.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/upload-limit.ini

# Copy nginx and start script
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 8080
EXPOSE 8080

# Run start script
CMD ["/start.sh"]
