#!/bin/bash

# Change UID of www-data user to match the host user
if [ -n "$HOST_UID" ] && [ "$NO_UID_CHANGE" != true ]
then
  usermod -u $HOST_UID www-data
  groupmod -g $HOST_UID www-data
elif [ -z "$HOST_UID" ] && [ "$NO_UID_CHANGE" != true ]
then
  usermod -u 1000 www-data
  groupmod -g 1000 www-data
fi

# Add domains to hosts file and generate SSL certificates for them
if [ -n "$TOU_DOMAINS_LIST" ]
then
  for domain in $TOU_DOMAINS_LIST; do
    echo "127.0.0.1 ${domain}" >> /etc/hosts
  done
  rm -f /etc/httpd/ssl/ssl.crt /etc/httpd/ssl/ssl.key
  mkcert -cert-file /etc/httpd/ssl/ssl.crt -key-file /etc/httpd/ssl/ssl.key $TOU_DOMAINS_LIST
fi

# Setup redis sessions
if [ -n "$TOU_REDIS_HOST" ]
then
  echo session.save_handler = redis >> /usr/local/etc/php/php.ini
  echo session.save_path = "tcp://\${TYPO3_REDIS_HOST}:6379" >> /usr/local/etc/php/php.ini
fi
