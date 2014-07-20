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
# This script sets up the environement and starts the configuration utility.
#
# Depends:
#   - $DATA_DIR
#

# Set environment variables.
. /opt/env.sh

# Make sure the building user has appropriate permissions on the data directory.
chown openwrt:wheel "$DATA_DIR" && chmod 755 "$DATA_DIR"

# Download source.
sudo -u openwrt -E /opt/git-clone.sh

# Start build.
sudo -u openwrt -E /opt/do-config.sh
