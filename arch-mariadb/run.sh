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
# This script starts a new or updates an existing MariaDB instance. The
# application container mounts data volumes from a data-only container.
#
# The data-only container is created only if a container with the same name does
# not exist yet. The application container is deleted and recreated every time.
#


################################################################################
#                                   PARAMETERS
################################################################################

APP_NAME="${APP_NAME:-mariadb}"           # Application container name.
DATA_NAME="${DATA_NAME:-$APP_NAME-data}"  # Data container name.
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

  APP_NAME     Application container name [$APP_NAME]
  DATA_NAME    Data container name [\$DATA_NAME-data]
  BACKUP_FILE  Path of application container backup file [\$APP_NAME_\$(date +%F_%H%M%S).backup.tar]
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
  echo "-- Removing old MariaDB container"
  docker stop "$APP_NAME" 2>/dev/null

  # Save parameters.
  MD_DATA_DIR="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*MD_DATA_DIR=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  MD_ROOT_PASS="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*MD_ROOT_PASS=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"

  # Create backup and remove container.
  docker export "$APP_NAME" > "$BACKUP_FILE"
  docker rm "$APP_NAME" 2>/dev/null
fi

# Data container.
docker inspect "$DATA_NAME" &>/dev/null \
  || docker run --name "$DATA_NAME" \
                -v "$MD_DATA_DIR" \
                busybox:latest true

# Application container.
echo "-- Creating new MariaDB container"
docker run -d --name "$APP_NAME" \
           ${MD_DATA_DIR+-e MD_DATA_DIR="$MD_DATA_DIR"} \
           ${MD_ROOT_PASS+-e MD_ROOT_PASS="$MD_ROOT_PASS"} \
           --volumes-from="$DATA_NAME" \
           ztombol/arch-mariadb:latest

# Unset variables in case this script was sourced from another.
unset MD_DATA_DIR MD_ROOT_PASS
