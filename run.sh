#!/bin/bash

if [ ! -z "$HOST_UID" ];
then
  usermod -u $HOST_UID www-data
  groupmod -g $HOST_UID www-data
else
  usermod -u 1000 www-data
  groupmod -g 1000 www-data
fi

apache2-foreground
