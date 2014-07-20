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
# Create new configuration files.
#

################################################################################
#                                    DEFAULTS
################################################################################

MD_NAME="${MD_NAME:-media-server}"
MD_USER="nobody"
MD_GROUP="nobody"
MD_DATA_MEDIA_DIR="$DATA_DIR/${MD_MEDIA_DIR-media}"
MD_DATA_DB_DIR="$DATA_DIR/${MD_DB_DIR-db}"


################################################################################
#                              CREATE CONFIGURATION
################################################################################

cat <<EOF
================================================================================
Initialising minidlna instance!
================================================================================
EOF

# User and Group ID change.
if [ "${MD_UID-x}" != "x" ] && [ "$MD_UID" != "$(id -ur "$MD_USER")" ] ; then
  usermod -u $MD_UID "$MD_USER"
  [ "$?" == "0" ] && echo "-- UID changed to $MD_UID!" \
                  || echo "-- ERROR: failed to change UID to $MD_UID!"
fi

if [ "${MD_GID-x}" != "x" ] && [ "$MD_UID" != "$(id -gr "$MD_GROUP")" ] ; then
  groupmod -g $MD_GID "$MD_GROUP"
  [ "$?" == "0" ] && echo "-- GID changed to $MD_GID!" \
                  || echo "-- ERROR: failed to change GID to $MD_GID!"
fi

# Creating directories and fixing ownerships.
mkdir -p "$MD_DATA_DB_DIR" "$MD_DATA_MEDIA_DIR"
chown "$MD_USER:$MD_GROUP" "/var/log/minidlna.log"
[ -e "$MD_DATA_DB_DIR/files.db" ] && chown "$MD_USER:$MD_GROUP" "$MD_DATA_DB_DIR/files.db"

# Copy configuration if does not exist yet.
if [ -e "$MD_CONF_DIR/minidlna.conf" ] ; then
  echo "-- Generating configuration file from EXISTING \`minidlna.conf'"
else
  echo "-- Generating configuration file from DEFAULT \`minidlna.conf'"
  cp /etc/minidlna.conf "$MD_CONF_DIR"
fi

# Generate `minidlna.conf'.
# NOTE: The parameter expansion at the end of rules substituting paths escapes
#       slashes in paths to prevent them interfering with sed's separators.
sed -ri -e "s/^(\s*)(#)?(friendly_name=).*$/\1\3${MD_NAME}/" \
        -e "s/^(\s*)(#)?(media_dir=).*$/\1\3${MD_DATA_MEDIA_DIR//\//\\/}/" \
        -e "s/^(\s*)(#)?(db_dir=).*$/\1\3${MD_DATA_DB_DIR//\//\\/}/" \
        -e "s/^(\s*)(#)?(user=).*$/\1\3${MD_USER}/" \
        "$MD_CONF_DIR/minidlna.conf"


################################################################################
#                                    SUMMARY
################################################################################

cat<<EOF
================================================================================
Successfully initialised minidlna with the following parameters!

  MD_NAME=$MD_NAME
  MD_UID=${MD_UID-$(id -ur $MD_USER)}
  MD_GID=${MD_GID-$(id -gr $MD_GROUP)}
  MD_MEDIA_DIR=$MD_MEDIA_DIR
  MD_DB_DIR=$MD_DB_DIR

================================================================================
EOF
