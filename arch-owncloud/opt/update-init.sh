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
# Update ownCloud configuration after updating the container.
#

# Version number.
OC_VERSION="$(grep '^\$OC_Version = array(.*);$' "$APP_DIR/version.php" | \
  sed -r -e 's/^\$OC_Version\s*=\s*array\((.*)\);$/\1/' -e 's/,/./g')"

if [ "${OC_VERSION:-x}" == x ] ; then
  cat<<EOF
================================================================================
ERROR: Cannot determine the version number of ownCloud!
================================================================================
EOF
  exit 1
fi

sed -ri "s/^(\s*'version'\s*=>\s*')[^']*(',.*)/\1$OC_VERSION\2/" \
  "$CONFIG_DIR/config.php"

# Print summary.
cat<<EOF
================================================================================
Successfully updated the following parameters in \`config.php'!

  version => $OC_VERSION

================================================================================
EOF

exit 0
