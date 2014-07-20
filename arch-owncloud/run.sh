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
# This script starts a new or updates an existing ownCloud instance. The
# application uses the database in the linked container and uses a host-mounted
# volume via a data-only container to store data.
#
# The data-only container is created only if a container with the same name does
# not exist yet. The application container is deleted and recreated every time.
#


################################################################################
#                                   PARAMETERS
################################################################################

#
# Script parameters.
#
APP_NAME="${APP_NAME:-owncloud}"          # Application container name.
DATA_NAME="${DATA_NAME:-$APP_NAME-data}"  # Data container name.
DB_NAME="${DB_NAME:-$APP_NAME-db}"        # Database container name.
CERT_FILE="${CERT_FILE:-owncloud.crt}"    # SSL certificate.
KEY_FILE="${KEY_FILE:-owncloud.key}"      # SSL key.
HTTP_PORT="${HTTP_PORT:-80}"              # HTTP port.
HTTPS_PORT="${HTTPS_PORT:-443}"           # HTTPS port.
HOST_DATA_DIR="${HOST_DATA_DIR:-$(pwd)/data}"
                                          # Directory of host mounted volume.
BACKUP_FILE="${BACKUP_FILE:-${APP_NAME}_$(date +%FT%H-%M-%S).backup.tar}"
                                          # Path of application backup file.

#
# Image specific. Default values have to follow `opt/*.sh`.
#
OC_DB_NAME="${OC_DB_NAME:-owncloud}"      # Database name.
OC_DB_USER="${OC_DB_USER:-owncloud}"      # Database user.
OC_DB_PASS="${OC_DB_PASS:-$(cat /dev/urandom | tr -cd [:alnum:] | fold -w 64 | head -n 1)}"
                                          # Password of OC_DB_USER.


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
  DB_NAME        Database container name [$DB_NAME]
  CERT_FILE      SSL Certificate file [$CERT_FILE]
  KEY_FILE       SSL Key file [$KEY_FILE]
  HTTP_PORT      HTTP host port [$HTTP_PORT]
  HTTPS_PORT     HTTPS host port [$HTTPS_PORT]
  HOST_DATA_DIR  Directory of host mounted volume [\$(pwd)]
  BACKUP_FILE    Path of application container backup file [\$APP_NAME_\$(date +%F_%H%M%S).backup.tar]

  OC_DB_USER     Database user [$OC_DB_USER]
  OC_DB_PASS     Passphrase of OC_DB_USER [<random>]
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
  echo "-- Removing old ownCloud container"
  docker stop "$APP_NAME" 2>/dev/null

  # Save parameters.
  OC_DB_NAME="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*OC_DB_NAME=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  OC_DB_USER="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*OC_DB_USER=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  OC_DB_PASS="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*OC_DB_PASS=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"
  OC_DATA_DIR="$(docker logs "$APP_NAME" 2>&1 | grep "^\s*OC_DATA_DIR=" | \
    sed -r 's/[^=]*=(.*)$/\1/')"

  # Create backup and remove container.
  docker export "$APP_NAME" > "$BACKUP_FILE"
  docker rm "$APP_NAME" 2>/dev/null
fi


################################################################################
#                                    DATABASE
################################################################################

# Are we updating the database?
docker inspect "$DB_NAME" &>/dev/null && DB_UPDATE=1

# Database data and application container.
APP_NAME="$DB_NAME" ../arch-mariadb/run.sh

# Create user and database for owncloud if we are initialising.
if [ "${DB_UPDATE-0}" -eq 0 ] ; then
  echo "-- Setting up database"

  echo -n "-- Waiting for the root password to show up in logs"
  while [ "${DB_ROOT_PASS:-x}" == x ] ; do
    echo -n .
    sleep 2
    DB_ROOT_PASS="$(docker logs "$DB_NAME" 2>&1 | grep "^\s*MD_ROOT_PASS=" | \
      sed -r 's/[^=]*=(.*)$/\1/')"
  done
  echo

  docker run --rm -t -i --link="$DB_NAME":db ztombol/arch-mariadb-client:latest \
    -uroot --password="$DB_ROOT_PASS" \
    <<EOF
      CREATE DATABASE $OC_DB_NAME DEFAULT CHARSET utf8;
      CREATE USER '$OC_DB_USER'@'%' IDENTIFIED BY '$OC_DB_PASS';
      GRANT ALL PRIVILEGES ON $OC_DB_NAME.* TO '$OC_DB_USER'@'%';
      FLUSH PRIVILEGES;
      EXIT
EOF

  unset DB_ROOT_PASS
fi


################################################################################
#                                    OWNCLOUD
################################################################################

# Data container.
docker inspect "$DATA_NAME" &>/dev/null \
  || docker run --name "$DATA_NAME" \
                -v "$HOST_DATA_DIR/data":/usr/share/webapps/owncloud/data \
                -v "$HOST_DATA_DIR/config":/usr/share/webapps/owncloud/config \
                -v "$HOST_DATA_DIR/certs":/etc/nginx/ssl \
                busybox:latest true

# Copy certificates if we are initialising.
if [ "${DB_UPDATE-0}" -eq 0 ] ; then
  # Certificate and key.
  echo '-- Copying certificate and private key'
  cp "$CERT_FILE" "$HOST_DATA_DIR/certs/owncloud.crt" || exit 1
  chmod 644 "$HOST_DATA_DIR/certs/owncloud.crt"

  cp "$KEY_FILE" "$HOST_DATA_DIR/certs/owncloud.key" || exit 1
  chmod 600 "$HOST_DATA_DIR/certs/owncloud.key"
fi

# Application container.
#
# Note: If you runt the container in interactive mode with `-i -t' for
#       debugging, be aware that the sed above will match the the carriage
#       returns when extracting parameters. So you will get '",234' insted of
#       '"1234",'. This will of course mess up the whole container.
#
echo "-- Starting new ownCloud container"
#docker run -i -t --name "$APP_NAME" \
docker run -d --name "$APP_NAME" \
           ${OC_DB_NAME+-e OC_DB_NAME="$OC_DB_NAME"} \
           ${OC_DB_USER+-e OC_DB_USER="$OC_DB_USER"} \
           ${OC_DB_PASS+-e OC_DB_PASS="$OC_DB_PASS"} \
           ${OC_DATA_DIR+-e OC_DATA_DIR="$OC_DATA_DIR"} \
           -e OC_DB_PASS="$OC_DB_PASS" \
           --link="$DB_NAME":db -p $HTTP_PORT:80/tcp -p $HTTPS_PORT:443/tcp \
           --volumes-from="$DATA_NAME" \
           ztombol/arch-owncloud:latest
#           ztombol/arch-owncloud:latest -i

# Unset variables in case we are sourced from another script.
unset OC_DB_PASS
