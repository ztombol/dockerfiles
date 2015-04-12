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
# This script starts a new `mysql` shell instance.
#


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

  DB_CONT  Database container name
  MC_ARGS  Arguments to the mysql client
EOF
  exit 0
fi


################################################################################
#                                      MAIN
################################################################################

# Exit if no database container specified.
if [ "${DB_CONT:-x}" == "x" ] ; then
  echo "Please specify the container of the database to connect to in \`DB_CONT'!"
  exit 1
fi

# Make sure we are running as root.
if [ "$EUID" -ne 0 ] ; then
  echo 'This script must be run as root.' 1>&2
  exit 1
fi

# Start client.
docker run --rm -t -i --link="$DB_CONT":db ztombol/arch-mariadb-client:latest $MC_ARGS
