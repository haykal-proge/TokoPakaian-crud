FROM php:8.2-fpm-bullseye

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy environment file
RUN cp .env.example .env

# Generate application key
RUN php artisan key:generate

# Expose Railway expected port (use dynamic env)
EXPOSE ${PORT}

# Run migrations and start Laravel on correct port
CMD sleep 10 && php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT}
