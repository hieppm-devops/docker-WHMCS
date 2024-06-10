FROM php:8.1-apache

# Install necessary PHP extensions and utilities
RUN set -xe \
    && apt-get update \
    && apt-get install -y libicu-dev --no-install-recommends \
    && apt-get install -y zlib1g-dev \
    libfreetype6-dev \
    libmagickwand-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libzip-dev \
    jpegoptim \
    optipng \
    gifsicle \
    sendmail \
    git-core \
    build-essential \
    openssl \
    libssl-dev \
    libonig-dev \
    python3 \
    zip \
    cron \
    libc-client-dev \
    libkrb5-dev \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli calendar intl \
    && docker-php-ext-configure gd \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install imap soap zip \
    && apt-get purge -y --auto-remove libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure production php.ini
RUN curl -sS https://raw.githubusercontent.com/php/php-src/master/php.ini-production \
    | sed -e 's/^;\(date.timezone.*\)/\1 \"Etc\/UTC\"/' \
    -e 's/^\(upload_max_filesize =\).*/\1 25M/' \
    -e 's/^\(post_max_size =\).*/\1 25M/' \
    > /usr/local/etc/php/php.ini

# Install ioncube loader
ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz /tmp/
RUN tar xvzfC /tmp/ioncube_loaders_lin_x86-64.tar.gz /tmp/ && \
    php_ext_dir="$(php -i | grep extension_dir | head -n1 | awk '{print $3}')" && \
    mv /tmp/ioncube/ioncube_loader_lin_8.1.so "${php_ext_dir}/" && \
    echo "zend_extension = $php_ext_dir/ioncube_loader_lin_8.1.so" \
    > /usr/local/etc/php/conf.d/00-ioncube.ini && \
    rm /tmp/ioncube_loaders_lin_x86-64.tar.gz && \
    rm -rf /tmp/ioncube

# Set the working directory
WORKDIR /var/www/html

# Copy WHMCS files
COPY . /var/www/html/

# Set permissions
RUN chown -R www-data:www-data .

# Expose port 80
EXPOSE 80
