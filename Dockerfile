FROM php:8.2-apache

# System dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip \
    libpng-dev libonig-dev libxml2-dev \
    libzip-dev libsodium-dev libfreetype6-dev \
    libjpeg62-turbo-dev nodejs npm \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install \
        pdo_mysql mbstring exif pcntl bcmath \
        gd zip sodium xml \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copy project files
COPY . .

# Create .env from example so artisan commands work at build and runtime
RUN cp .env.example .env

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev --ignore-platform-req=ext-grpc

# Build frontend assets
RUN npm install && npm run production 2>/dev/null || true

# Cache config, routes and views at build time
RUN php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Apache virtual host config
COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf

# Startup script
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
