#!/usr/bin/bash

#
# This script is the entry point of the container. It initialises and starts
# ownCloud.
#

export APP_DIR="/usr/share/webapps/owncloud"
export CONFIG_DIR="$APP_DIR/config/"

if [ -f "/opt/first-run" ] ; then
  # Initialising.
  grep -s "^\s*'installed'\s*=>\s*true,$" "$CONFIG_DIR/config.php" > /dev/null
  if [ "$?" -eq 1 ] || [ ! -f "$CONFIG_DIR/config.php" ] ; then
    # Setting up new instance.
    /opt/init.sh
  else
    # Updating, previous configuration.
    /opt/update-init.sh
    /opt/update-start.sh
  fi
  rm /opt/first-run
else
  # Container already intialised. Update database address.
  /opt/update-start.sh
fi

# Start services. 
/usr/bin/supervisord -c /etc/supervisord.conf
