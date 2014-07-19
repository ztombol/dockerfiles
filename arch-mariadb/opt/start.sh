#!/usr/bin/bash

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
