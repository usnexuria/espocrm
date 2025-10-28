FROM php:8.2-apache

# Install system dependencies for PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    zip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_pgsql mbstring intl gd xml zip \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy EspoCRM files
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Increase memory limit and run Composer as www-data user
USER www-data
RUN php -d memory_limit=4G /usr/bin/composer install --no-dev --optimize-autoloader
USER root

# Expose port
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
