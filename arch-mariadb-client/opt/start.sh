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
# This script is the entry point of the container. It starts and connects
# `mysql` to the server in the linked container.
#

# Exit if there is no database container linked.
if [ "${DB_NAME-x}" == "x" ] ; then
  cat<<EOF
================================================================================
ERROR: Please link the database container to talk to under the alias \`db'"

  # docker ... --link=<db-cont>:db ...

================================================================================
EOF
  exit 1
fi

# Extract host and port of database server.
MC_HOST="$(echo $DB_PORT | sed -r 's;^[^:]+://(.+):[0-9]+$;\1;')"
MC_PORT="${DB_PORT##*:}"

# Connect to database server.
echo "-- Connecting to database on $HOST:$PORT"
/usr/bin/mysql -h "$MC_HOST" -P "$MC_PORT" $@
