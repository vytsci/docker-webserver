FROM php:7.1-apache

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install \
       libfreetype6-dev \
       libjpeg62-turbo-dev \
       libmcrypt-dev \
       libpng-dev \
       zlib1g-dev \
       libicu-dev \
       libldb-dev \
       libldap2-dev

# Clean up all the mess
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install & configure php extensions
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli bcmath intl mbstring zip ldap gd

# Install & enable xdebug
RUN pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug

# Prepare apache
RUN a2enmod rewrite vhost_alias speling && a2ensite * && service apache2 restart
