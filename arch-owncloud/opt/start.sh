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
