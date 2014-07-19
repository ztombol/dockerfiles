#!/usr/bin/bash

#
# Script initialising Transmission.
#

# Creating directories and fixing permissions.
mkdir -p "$TM_HOME"/{download,incomplete,watch} "$TM_CONFIG_DIR"
chown -R transmission:transmission "$TM_HOME"/{download,incomplete,watch,.config}

# Generate new configuration file if one does not exist yet.
if [ ! -e "$TM_CONFIG_DIR/settings.json" ] ; then
  echo "-- Using DEFAULT configuration"
  transmission-daemon -d 2> "$TM_CONFIG_DIR/settings.json"
else
  echo "-- Using EXISTING configuration"
fi
chmod 600 "$TM_CONFIG_DIR/settings.json" && \
  chown transmission:transmission "$TM_CONFIG_DIR/settings.json"

# Update RPC whitelist.
/opt/rpc-whitelist.sh

# Print summary.
cat<<EOF
================================================================================
Successfully initialised Transmission with the following parameters!

  TM_RPC_WHITELIST=$TM_RPC_WHITELIST

================================================================================
EOF
