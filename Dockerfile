# Use PHP 8.2 with Apache
FROM php:8.2-apache

# Install system dependencies and PHP extensions required for EspoCRM
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    libpq-dev \
    libicu-dev \
    libonig-dev \
    curl \
    && docker-php-ext-install pdo pdo_pgsql mbstring intl gd

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy EspoCRM files
COPY . .

# Ensure permissions for composer
RUN chown -R www-data:www-data /var/www/html

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Enable Apache rewrite module
RUN a2enmod rewrite

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
