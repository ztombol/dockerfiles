#!/usr/bin/bash

#
# This script is the entry point of the container. It initialises and starts
# Nginx.
#

export NX_DATA_DIR="/data"

if [ -f /opt/first-run ] ; then
  # First run. Initialise container.
  /opt/init.sh
  rm /opt/first-run
fi

# Start Nginx.
/usr/bin/supervisord -c /etc/supervisord.conf
