FROM php:7.1.9-apache

RUN echo "deb [check-valid-until=no] http://cdn-fastly.deb.debian.org/debian jessie main" > /etc/apt/sources.list.d/jessie.list
RUN echo "deb [check-valid-until=no] http://archive.debian.org/debian jessie-backports main" > /etc/apt/sources.list.d/jessie-backports.list
RUN sed -i '/deb http:\/\/deb.debian.org\/debian jessie-updates main/d' /etc/apt/sources.list

# Install modules
RUN apt-get -o Acquire::Check-Valid-Until=false update && apt-get install -y \
	vim \
	wget \
	curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
	graphicsmagick \
	graphicsmagick-imagemagick-compat \
	mysql-client \
	libmemcached-dev \
	libxml2-dev \
	libldap2-dev \
	libapache2-mod-rpaf \
        freetds-bin \
        freetds-common \ 
        freetds-dev \
        locales \
        unixodbc \
        unixodbc-dev \
        && apt-get clean \
        && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
        && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a 

RUN docker-php-ext-install iconv mcrypt mbstring soap 
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu 
RUN docker-php-ext-install gd pdo_mysql mysqli zip ldap 
RUN pecl install memcached \
    && pecl install xdebug \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv

RUN cp /usr/share/i18n/SUPPORTED /etc/locale.gen && \
    locale-gen
ADD apache2.conf /etc/apache2/apache2.conf
RUN a2enmod rewrite && \
    a2enmod ssl && \
    a2enmod headers && \
    a2enmod expires && \
    a2enmod remoteip

ADD php.ini /usr/local/etc/php/php.ini
ADD run.sh /usr/local/bin/run.sh
ADD ssl /etc/httpd/ssl
RUN chmod +x /usr/local/bin/run.sh
EXPOSE 80
EXPOSE 443
CMD ["/usr/local/bin/run.sh"]
