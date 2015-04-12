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
# Updates the RPC whitelist in `settings.json'.
#
# Depends:
#   - $TM_CONFIG_DIR
#   - $TM_RPC_WHITELIST
#

################################################################################
#                                      MAIN
################################################################################

# Update RPC whitelist.
sed -ri "s/^(\s*\"rpc-whitelist\":\s*).*/\1\"$TM_RPC_WHITELIST\",/" \
  "$TM_CONFIG_DIR/settings.json"
