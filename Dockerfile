FROM php:7.1.17-apache

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install zlib1g-dev libicu-dev g++ \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN docker-php-ext-install pdo pdo_mysql mysqli bcmath intl

# Prepare apache
RUN a2enmod rewrite vhost_alias speling && a2ensite * && service apache2 restart
