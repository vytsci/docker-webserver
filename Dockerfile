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
       libaio-dev \
       libldb-dev \
       libldap2-dev

ADD oracle-instantclient12.2-basic_12.2.0.1.0-2_amd64.deb /tmp/
ADD oracle-instantclient12.2-devel_12.2.0.1.0-2_amd64.deb /tmp/
ADD oracle-instantclient12.2-jdbc_12.2.0.1.0-2_amd64.deb /tmp/
ADD oracle-instantclient12.2-odbc_12.2.0.1.0-2_amd64.deb /tmp/
ADD oracle-instantclient12.2-sqlplus_12.2.0.1.0-2_amd64.deb /tmp/
ADD oracle-instantclient12.2-tools_12.2.0.1.0-2_amd64.deb /tmp/

RUN dpkg -i /tmp/oracle-instantclient12.2-basic_12.2.0.1.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.2-devel_12.2.0.1.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.2-jdbc_12.2.0.1.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.2-sqlplus_12.2.0.1.0-2_amd64.deb
RUN dpkg -i /tmp/oracle-instantclient12.2-tools_12.2.0.1.0-2_amd64.deb

RUN echo 'instantclient,/usr/lib/oracle/12.2/client64/lib' | pecl install -f oci8

# Clean up all the mess
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install & configure php extensions
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr,12.2 \
    && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/lib/oracle/12.2/client64/lib \
    && docker-php-ext-install -j$(nproc) pdo_mysql pdo_oci mysqli oci8 bcmath intl mbstring mcrypt zip ldap gd

# Install & enable PECL extensions
RUN pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug
RUN pecl install apcu && docker-php-ext-enable apcu

# Prepare apache
RUN a2enmod rewrite vhost_alias speling && a2ensite * && service apache2 restart
