#!/bin/bash

export PGU_BUILD=$(cat /var/www/version)

if [ ! -z "$HOST_UID" ] & [ "$NO_UID_CHANGE" != true ]
then
  usermod -u $HOST_UID www-data
  groupmod -g $HOST_UID www-data
elif [ -z "$HOST_UID" ] & [ "$NO_UID_CHANGE" != true ]
then
  usermod -u 1000 www-data
  groupmod -g 1000 www-data
fi

# Lancement de Apache
#apache2-foreground
/usr/sbin/apachectl -D FOREGROUND

