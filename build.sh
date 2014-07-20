#!/usr/bin/bash

#
# Copyright (C)  2013  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
#
# This file is part of Dockerfiles.
#
# Dockerfiles is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Dockerfiles is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Dockerfiles.  If not, see <http://www.gnu.org/licenses/>.
#

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
