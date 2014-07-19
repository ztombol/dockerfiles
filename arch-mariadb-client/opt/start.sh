#!/usr/bin/bash

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
