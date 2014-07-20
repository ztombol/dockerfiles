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
