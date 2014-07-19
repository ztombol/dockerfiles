#!/usr/bin/bash

#
# Script starting minidlna and optionally initialising or updating it's
# configuration.
#

export DATA_DIR="/data"
export MD_CONF_DIR="$DATA_DIR"

if [ -e "/opt/first-run" ] ; then
  # First run. Initialise configuration.
  /opt/init.sh
  rm /opt/first-run
else
  # Configuration exist.
  echo "-- Using existing setup."
fi

# Start minidlna.
/usr/bin/minidlnad -S -f "$MD_CONF_DIR/minidlna.conf" -P /run/minidlna/minidlna.pid
