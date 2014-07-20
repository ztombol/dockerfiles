#!/usr/bin/bash

#
# Copyright (C)  2013  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
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
