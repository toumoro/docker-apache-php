FROM php:7.2.14-apache
# Install modules
RUN apt-get update && apt-get install -y \
	vim \
	wget \
	curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
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

RUN docker-php-ext-install iconv mbstring soap intl
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ 
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu 
RUN docker-php-ext-install gd pdo_mysql mysqli zip ldap
RUN pecl install mcrypt-1.0.2 memcached

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
ADD composer-setup.sh /root/composer-setup.sh
RUN chmod +x /root/composer-setup.sh
WORKDIR /root
RUN ./composer-setup.sh
WORKDIR /var/www/html
EXPOSE 80
EXPOSE 443
CMD ["/usr/local/bin/run.sh"]
