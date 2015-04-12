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
# This script starts a new or updates an existing minidlna instance. The
# application container mounts a host mounted volume via a data-only container.
#
# The data-only container is created only if a container with the same name does
# not exist yet. The application container is deleted and recreated every time.
#


################################################################################
#                                   PARAMETERS
################################################################################

APP_NAME="${APP_NAME:-minidlna}"          # Application container name.
DATA_NAME="${DATA_NAME:-$APP_NAME-data}"  # Data container name.
SRV_PORT="${SRV_PORT:-8200}"              # Media server port.
SSDP_PORT="${SSDP_PORT:-1900}"            # Service discivery port.
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
  SRV_PORT       Media server port [$SRV_PORT]
  SSDP_PORT      Service discivery port [$SSDP_PORT]
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
  MD_NAME="$(docker logs "$APP_NAME" | grep "^\s*MD_NAME=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  MD_MEDIA_DIR="$(docker logs "$APP_NAME" | grep "^\s*MD_MEDIA_DIR=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  MD_DB_DIR="$(docker logs "$APP_NAME" | grep "^\s*MD_DB_DIR=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  MD_UID="$(docker logs "$APP_NAME" | grep "^\s*MD_UID=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  MD_GID="$(docker logs "$APP_NAME" | grep "^\s*MD_GID=" | \
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
           ${MD_NAME+-e MD_NAME="$MD_NAME"} \
           ${MD_MEDIA_DIR+-e MD_MEDIA_DIR="$MD_MEDIA_DIR"} \
           ${MD_DB_DIR+-e MD_DB_DIR="$MD_DB_DIR"} \
           ${MD_UID+-e MD_UID="$MD_UID"} \
           ${MD_GID+-e MD_GID="$MD_GID"} \
           -p $SRV_PORT:8200/tcp -p $SSDP_PORT:1900/udp \
           --volumes-from="$DATA_NAME" \
           --net="host" \
           ztombol/arch-minidlna:latest
