FROM php:7.4-apache

# Install necessary PHP extensions and utilities
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    wget \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install pdo pdo_mysql \
    && docker-php-ext-install zip \
    && apt-get clean

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Download and install ionCube Loader
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvf ioncube_loaders_lin_x86-64.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ \
    && rm -rf ioncube*

# Verify the ionCube Loader file exists
RUN ls -l /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so

# Set the LD_LIBRARY_PATH environment variable
# ENV LD_LIBRARY_PATH=/usr/local/lib/php/extensions/no-debug-non-zts-20190902:$LD_LIBRARY_PATH

# Create ionCube configuration file
RUN echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20190902/ioncube_loader_lin_7.4.so" > /usr/local/etc/php/conf.d/00-ioncube.ini

# Set the working directory
WORKDIR /var/www/html

# Copy WHMCS files
# COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data .

# Expose port 80
EXPOSE 80

# USER root


