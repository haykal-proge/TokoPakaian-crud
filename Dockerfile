FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim unzip git curl

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy existing application directory
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy environment example
RUN cp .env.example .env

# Generate application key
RUN php artisan key:generate

# Expose port 8000 and start server
EXPOSE 8000
CMD php artisan serve --host=0.0.0.0 --port=8000
