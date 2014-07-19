#!/usr/bin/bash

#
# Script for easy building of Docker images. Set the NAMESPACE and REPOSITORY
# variables to use it with your image.
#

NAMESPACE='ztombol'
REPOSITORY='arch-nginx'

if [ "$EUID" -ne 0 ] ; then
  echo 'This script must be run as root.' 1>&2
  exit 1
fi

docker build -t "$NAMESPACE/$REPOSITORY" .
