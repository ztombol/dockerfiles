#!/usr/bin/bash

#
# This script is the entry point of the container. It initialises or updates,
# and starts Transmission.
#

export TM_HOME='/var/lib/transmission'
export TM_CONFIG_DIR="$TM_HOME/.config/transmission-daemon"
export TM_RPC_WHITELIST="${TM_RPC_WHITELIST:-127.0.0.1}"

if [ -f "/opt/first-run" ] ; then
  # First run of container. Initialise!
  /opt/init.sh
  rm /opt/first-run
fi

# Start transmission.
su -l -s /bin/bash -c "transmission-daemon -f --log-error" transmission
