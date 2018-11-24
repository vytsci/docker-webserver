FROM php:7.1-apache

# Install selected extensions and other stuff
RUN apt-get update
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

# Clean up all the mess
RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install & configure php extensions
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) pdo_mysql mysqli bcmath intl mbstring mcrypt zip ldap gd soap

# Install & enable PECL extensions
RUN pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug
RUN pecl install apcu && docker-php-ext-enable apcu

# Install OCI8
ENV ORACLE_BASE "/usr/lib/oracle"
ENV ORACLE_HOME "$ORACLE_BASE/12.2/client64"
ENV LD_LIBRARY_PATH "$ORACLE_HOME/lib"
RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/lib/oracle/12.2/client64/lib
RUN docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr,12.2
RUN docker-php-ext-install -j$(nproc) oci8 pdo_oci

# Prepare apache
RUN a2enmod rewrite vhost_alias speling && a2ensite * && service apache2 restart
