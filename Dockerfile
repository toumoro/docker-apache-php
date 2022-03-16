FROM php:7.4-apache
# Install modules
RUN apt-get update && apt-get install -y \
	vim \
	wget \
        git \
	curl \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
	graphicsmagick \
	graphicsmagick-imagemagick-compat \
	default-mysql-client \
        libonig-dev \
        libzip-dev \
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
RUN docker-php-ext-configure gd --with-jpeg=/usr/include/ --with-freetype=/usr/include/




 
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu 
RUN docker-php-ext-install gd pdo_mysql mysqli zip ldap
RUN pecl install mcrypt memcached

RUN echo "ca_FR.UTF-8 UTF-8\nca_FR ISO-8859-15\nen_CA.UTF-8 UTF-8\nen_CA ISO-8859-1\nen_GB.UTF-8 UTF-8\nen_GB ISO-8859-1\nen_GB.ISO-8859-15 ISO-8859-15\nen_US.UTF-8 UTF-8\nen_US ISO-8859-1\nen_US.ISO-8859-15 ISO-8859-15\nfr_CA.UTF-8 UTF-8\nfr_CA ISO-8859-1\nfr_FR.UTF-8 UTF-8\nfr_FR ISO-8859-1\nfr_FR@euro ISO-8859-15" > /etc/locale.gen && \
    locale-gen

ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf


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
