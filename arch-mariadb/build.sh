#!/usr/bin/bash

#
# Script for easy building of Docker images. To use it, copy it to the directory
# of the Dockerfile and set the NAMESPACE and REPOSITORY variables.
#

NAMESPACE='ztombol'
REPOSITORY='arch-mariadb'

if [ "$EUID" -ne 0 ] ; then
  echo 'This script must be run as root.' 1>&2
  exit 1
fi

docker build -t "$NAMESPACE/$REPOSITORY" .
