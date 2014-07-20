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
# This script starts a new or updates an existing Transmission instance. The
# application container mounts data volumes from a data-only container.
#
# The data-only container is created only if a container with the same name does
# not exist yet. The application container is deleted and recreated every time.
#


################################################################################
#                                   PARAMETERS
################################################################################

APP_NAME="${APP_NAME:-transmission}"      # Application container name.
DATA_NAME="${DATA_NAME:-$APP_NAME-data}"  # Data container name.
HTTP_PORT="${HTTP_PORT:-9091}"            # HTTP port.
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
  DATA_NAME      Data container name [\$DATA_NAME-data]
  HTTP_PORT      HTTP host port [$HTTP_PORT]
  HOST_DATA_DIR  Directory of host mounted volume [\$(pwd)/data]
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
  echo "-- Removing old Transmission container"
  docker stop "$APP_NAME" 2>/dev/null

  # Save parameters.
  TM_RPC_WHITELIST="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*TM_RPC_WHITELIST=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"

  # Create backup and remove container.
  docker export "$APP_NAME" > "$BACKUP_FILE"
  docker rm "$APP_NAME" 2>/dev/null
fi

# Data container.
docker inspect "$DATA_NAME" &>/dev/null \
  || docker run --name "$DATA_NAME" \
                -v "$HOST_DATA_DIR":/var/lib/transmission \
                busybox:latest true

# Application container.
echo "-- Creating new Transmission container"
docker run -d --name "$APP_NAME" -p 9091:9091 --volumes-from="$DATA_NAME" \
           -e TM_RPC_WHITELIST="$TM_RPC_WHITELIST" \
           ztombol/arch-transmission:latest
