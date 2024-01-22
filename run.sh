#!/bin/bash

/usr/local/bin/configure.sh

# Lancement de Apache
#apache2-foreground
/usr/sbin/apachectl -D FOREGROUND
