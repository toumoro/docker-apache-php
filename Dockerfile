FROM php:5.5.28-apache
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
	libldap2-dev \
	libapache2-mod-rpaf \
        freetds-bin \
        freetds-common \ 
        freetds-dev \
        locales \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a \
    && docker-php-ext-configure mssql \
    && docker-php-ext-install mssql \
    && docker-php-ext-install iconv mcrypt mbstring soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install gd mysql pdo_mysql mysqli zip ldap \
    && pecl install memcache \
    && pecl install memcached \
    && pecl install xdebug \
    && apt-get clean

# Setup locales
RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen \
    && echo fr_CA.UTF-8 UTF-8 >> /etc/locale.gen
RUN dpkg-reconfigure -f noninteractive locales

ADD apache2.conf /etc/apache2/apache2.conf
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers
ADD php.ini /usr/local/etc/php/php.ini
ADD run.sh /usr/local/bin/run.sh
ADD ssl /etc/httpd/ssl
RUN chmod +x /usr/local/bin/run.sh
EXPOSE 80
EXPOSE 443
CMD ["/usr/local/bin/run.sh"]
