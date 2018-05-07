FROM php:7.1.17-apache

COPY ./apache.conf /etc/apache2/sites-available/000-default.conf

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install php-memcached \
    && docker-php-ext-install pdo pdo_mysql mysqli bcmath gd intl \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Prepare apache
RUN a2enmod vhost_alias speling && service apache2 restart
