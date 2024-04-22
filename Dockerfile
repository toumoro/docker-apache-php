FROM debian:bookworm

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
    php8.2 \
    php8.2-cli \
    php8.2-common \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-ldap \
    php8.2-mbstring \
    php8.2-mysql \
    php8.2-mysqli \
    php8.2-redis \
    php8.2-soap \
    php8.2-xml \
    php8.2-zip \
    php-pear \
    php8.2-dev \
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

ADD apache2.conf /etc/apache2/apache2.conf
ADD 000-default.conf /etc/apache2/sites-enabled/000-default.conf
ADD default-ssl.conf /etc/apache2/sites-enabled/default-ssl.conf
ADD php.ini /etc/php/8.2/apache2/php.ini
ADD php.ini /etc/php/8.2/cli/php.ini

ADD configure.sh /usr/local/bin/configure.sh
ADD run.sh /usr/local/bin/run.sh
ADD ssl /etc/httpd/ssl
RUN chmod +x /usr/local/bin/configure.sh
RUN chmod +x /usr/local/bin/run.sh
ADD composer-setup.sh /root/composer-setup.sh
RUN chmod +x /root/composer-setup.sh

WORKDIR /root
RUN ./composer-setup.sh
WORKDIR /var/www

EXPOSE 80
EXPOSE 443

CMD ["/usr/local/bin/run.sh"]
