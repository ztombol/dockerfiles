#!/usr/bin/bash

#
# Copyright (C)  2014  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
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
# Script for easy building of Docker images. Set the NAMESPACE and REPOSITORY
# variables to use it with your image.
#

NAMESPACE='ztombol'
REPOSITORY='arch-base'

if [ "$EUID" -ne 0 ] ; then
  echo 'This script must be run as root.' 1>&2
  exit 1
fi

docker build -t "$NAMESPACE/$REPOSITORY" .
