FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    apache2 \
    vim \
    wget \
    git \
    curl \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    graphicsmagick \
    libonig-dev \
    libzip-dev \
    libxml2-dev \
    libldap2-dev \
    libapache2-mod-rpaf \
    freetds-bin \
    freetds-common \
    freetds-dev \
    locales \
    unixodbc \
    unixodbc-dev \
    default-mysql-client \
    php7.4 \
    php7.4-cli \
    php7.4-common \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-ldap \
    php7.4-mbstring \
    php7.4-mysql \
    php7.4-mysqli \
    php7.4-redis \
    php7.4-soap \
    php7.4-xml \
    php7.4-zip \
    php7.4-dev \
    php-pear \
    && apt-get clean \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.so /usr/lib/libsybdb.so \
    && ln -s /usr/lib/x86_64-linux-gnu/libsybdb.a /usr/lib/libsybdb.a


RUN echo "ca_FR.UTF-8 UTF-8\nca_FR ISO-8859-15\nen_CA.UTF-8 UTF-8\nen_CA ISO-8859-1\nen_GB.UTF-8 UTF-8\nen_GB ISO-8859-1\nen_GB.ISO-8859-15 ISO-8859-15\nen_US.UTF-8 UTF-8\nen_US ISO-8859-1\nen_US.ISO-8859-15 ISO-8859-15\nfr_CA.UTF-8 UTF-8\nfr_CA ISO-8859-1\nfr_FR.UTF-8 UTF-8\nfr_FR ISO-8859-1\nfr_FR@euro ISO-8859-15" > /etc/locale.gen && \
    locale-gen

# Generating locally trusted CA
RUN curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest| grep browser_download_url  | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -
RUN mv mkcert-v*-linux-amd64 mkcert
RUN chmod a+x mkcert
RUN mv mkcert /usr/local/bin
RUN mkcert -install

RUN a2enmod rewrite && \
    a2enmod ssl && \
    a2enmod headers && \
    a2enmod expires && \
    a2enmod remoteip

ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
ADD php.ini /etc/php/7.4/apache2/php.ini


ADD php.ini /etc/php/7.4/cli/php.ini
ADD run.sh /usr/local/bin/run.sh
ADD configure.sh /usr/local/bin/configure.sh
ADD ssl /etc/httpd/ssl
RUN chmod +x /usr/local/bin/run.sh
ADD composer-setup.sh /root/composer-setup.sh
RUN chmod +x /root/composer-setup.sh
WORKDIR /root
RUN ./composer-setup.sh
WORKDIR /var/www

EXPOSE 80
EXPOSE 443

CMD ["/usr/local/bin/run.sh"]
