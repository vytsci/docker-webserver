FROM php:7.1.26-apache

# Install selected extensions and other stuff
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install libapache2-mod-fcgid
RUN apt-get -y install libfreetype6-dev
RUN apt-get -y install libjpeg62-turbo-dev
RUN apt-get -y install libmcrypt-dev
RUN apt-get -y install libpng-dev
RUN apt-get -y install zlib1g-dev
RUN apt-get -y install libicu-dev
RUN apt-get -y install libaio-dev
RUN apt-get -y install libldb-dev
RUN apt-get -y install libldap2-dev
RUN apt-get -y install libxml2-dev
RUN apt-get -y install libmemcached-dev
RUN apt-get -y install libxrender1
RUN apt-get -y install libfontconfig1 -y
RUN apt-get -y install wget
RUN apt-get -y install git
RUN apt-get -y install nano

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

RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.3/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz -O /tmp/wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
RUN cd /tmp && tar xvf wkhtmltox-0.12.3_linux-generic-amd64.tar.xz
RUN mv /tmp/wkhtmltox/bin/wkhtmlto* /usr/local/bin/

# Clean up all the mess
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install & configure php extensions
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli bcmath intl mbstring mcrypt zip ldap gd soap

# Install & enable PECL extensions
RUN pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug
RUN pecl install apcu && docker-php-ext-enable apcu
RUN pecl install redis && docker-php-ext-enable redis
RUN pecl install memcached && docker-php-ext-enable memcached

# Install OCI8
ENV ORACLE_BASE "/usr/lib/oracle"
ENV ORACLE_HOME "$ORACLE_BASE/12.2/client64"
ENV LD_LIBRARY_PATH "$ORACLE_HOME/lib"
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/lib/oracle/12.2/client64/lib
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr,12.2
RUN docker-php-ext-install -j$(nproc) oci8 pdo_oci

# Prepare apache
RUN rm /etc/apache2/sites-available/*
RUN rm /etc/apache2/sites-enabled/*
RUN a2enmod fcgid rewrite vhost_alias speling ssl
