FROM php:5.4.43-apache
# Install modules
RUN apt-get update && apt-get install -y \
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
	libldap2-dev\
    && docker-php-ext-install iconv mcrypt mbstring soap zip\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
    && docker-php-ext-install gd mysql pdo_mysql mysqli ldap \
    && pecl install memcache \
    && pecl install memcached \
    && pecl install xdebug \
    && apt-get clean
RUN adduser www
ADD apache2.conf /etc/apache2/apache2.conf
RUN a2enmod rewrite
ADD php.ini /usr/local/etc/php/php.ini
ADD run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
EXPOSE 80
CMD ["/usr/local/bin/run.sh"]
