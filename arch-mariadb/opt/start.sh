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
# This script is the entry point of the container. It initialises and starts
# MariaDB.
#

export MD_DATA_DIR="${MD_DATA_DIR:-/data}"

if [ -f "/opt/first-run" ] ; then
  # First run. Initialise container.
  if [ ! "$(ls -A "$MD_DATA_DIR")" ] ; then
    # Initialise new database.
    /opt/init.sh || exit 1
  else
    # Use existing database.
    /opt/update.sh || exit 1
  fi
  rm /opt/first-run
elif [ ! "$(ls -A "$MD_DATA_DIR")" ] ; then
  # ERROR: Not the first run of the container, but still there is no database.
  cat <<EOF
================================================================================
ERROR: This is not the first run of this container and there is no database data
       in \`$MD_DATA_DIR'! You either forgot to mount the data volume or
       initialisation of this container has failed previously. Check the logs to
       see what is wrong.

         # docker logs $(hostname)

================================================================================
  exit 1
EOF
fi

# Start MariaDB.
/usr/bin/mysqld --user=mysql --pid-file=/run/mysqld/mysqld.pid
