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
# This script starts a new or updates an existing nginx instance. The
# application container mounts a host mounted volume via a data-only container.
#
# The data-only container is created only if a container with the same name does
# not exist yet. The application container is deleted and recreated every time.
#


################################################################################
#                                   PARAMETERS
################################################################################

APP_NAME="${APP_NAME:-nginx-php}"         # Application container name.
DATA_NAME="${DATA_NAME:-$APP_NAME-data}"  # Data container name.
HTTP_PORT="${HTTP_PORT:-80}"              # HTTP port.
HTTPS_PORT="${HTTPS_PORT:-443}"           # HTTPS port.
HOST_DATA_DIR="${HOST_DATA_DIR:-$(pwd)/data}"
                                          # Directory of host mounted volume.
BACKUP_FILE="${BACKUP_FILE:-${APP_NAME}_$(date +%FT%H-%M-%S).backup.tar}"
                                          # Path of application backup file.


################################################################################
#                                     USAGE
################################################################################

if [ "$#" != "0" ] ; then
  cat <<EOF
USAGE:
  $0 [args...]

ARGUMENTS:
  Presence of any argument causes the script to display this help and exit.

ENVIRONMENT:
  In addition to the variables listed bellow, all environment variables
  supported by the container (supplied to run via \`-e') can be used here.

  APP_NAME       Application container name [$APP_NAME]
  DATA_NAME      Data container name [$DATA_NAME]
  HTTP_PORT      HTTP host port [$HTTP_PORT]
  HTTPS_PORT     HTTPS host port [$HTTPS_PORT]
  HOST_DATA_DIR  Directory of host mounted volume [\$(pwd)]
  BACKUP_FILE    Path of application container backup file [\$APP_NAME_\$(date +%F_%H%M%S).backup.tar]
EOF
  exit 0
fi


################################################################################
#                                      MAIN
################################################################################

# Make sure we are running as root.
if [ "$EUID" -ne 0 ] ; then
    echo 'This script must be run as root.' 1>&2
    exit 1
fi

# Prepare and cleanup if we are updating.
docker inspect "$APP_NAME" &>/dev/null
if [ "$?" -eq 0 ] ; then
  docker stop "$APP_NAME" 2>/dev/null

  # Save parameters.
  NX_DOC_ROOT="$(docker logs "$APP_NAME" | grep "^\s*NX_DOC_ROOT=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"

  # Create backup and remove container.
  docker export "$APP_NAME" > "$BACKUP_FILE"
  docker rm "$APP_NAME" 2>/dev/null
fi

# Data container.
docker inspect "$DATA_NAME" &>/dev/null \
  || docker run --name "$DATA_NAME" \
                -v "$HOST_DATA_DIR":/data \
                busybox:latest true

# Application container.
docker run -d --name "$APP_NAME" \
           ${NX_DOC_ROOT+-e NX_DOC_ROOT="$NX_DOC_ROOT"} \
           -p $HTTP_PORT:80/tcp -p $HTTPS_PORT:443/tcp \
           --volumes-from="$DATA_NAME" \
           ztombol/arch-nginx-php:latest
