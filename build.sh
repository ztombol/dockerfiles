#!/usr/bin/bash

#
# Script for easily building multiple Docker images in a specific order. Copy it
# to the parent directory of the Docker images to be built and set the NAMESPACE
# and IMAGES variables.
#

NAMESPACE='ztombol'
IMAGES=(
  arch-base
  arch-supervisor
  arch-nginx
  arch-nginx-php
  arch-mariadb
  arch-mariadb-client
  arch-owncloud
  arch-minidlna
  arch-transmission
  arch-openwrt-buildroot
)

if [ "$EUID" -ne 0 ] ; then
    echo 'This script must be run as root.' 1>&2
    exit 1
fi

for IMAGE in "${IMAGES[@]}" ; do
  echo "-- building $IMAGE"
  cd "$IMAGE"
  ./build.sh
  cd ..
done
