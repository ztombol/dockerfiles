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
# Update database address (it may differ after restarting containers).
#

# Update database address
OC_DB_HOST="$(echo $DB_PORT | sed -r 's;^[^:]+://;;')"

sed -ri "s/^(\s*'dbhost'\s*=>\s*')[^']*(',.*)/\1$OC_DB_HOST\2/" \
  "$CONFIG_DIR/config.php"

# Print summary.
cat<<EOF
================================================================================
Database address updated to \`$OC_DB_HOST'!
================================================================================
EOF
