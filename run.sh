#!/bin/bash

userdel -r www
adduser www --disabled-password --gecos ",,," -u $HOST_UID
apache2-foreground
