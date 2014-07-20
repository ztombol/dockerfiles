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
# Initialise ownCloud configuration.
#

################################################################################
#                                    DEFAULTS
################################################################################

OC_DB_TYPE='mysql'
OC_DB_NAME="${OC_DB_NAME:-owncloud}"
OC_DB_USER="${OC_DB_USER:-owncloud}"
OC_DATA_DIR="${OC_DATA_DIR:-/usr/share/webapps/owncloud/data}"


################################################################################
#                               CHECK REQUIREMENTS
################################################################################

cat <<EOF
================================================================================
Initialising ownCloud!
================================================================================
EOF

# Exit if there is no database container linked.
if [ "${DB_NAME-x}" == "x" ] ; then
  cat<<EOF
ERROR: Please link the database container to talk to under the alias \`db'!"

  # docker ... --link=<db-cont>:db ...

EOF
  exit 1
fi

# Check whether database password is specified.
OC_DB_HOST="$(echo $DB_PORT | sed -r 's;^[^:]+://;;')"
if [ "${OC_DB_PASS-x}" == "x" ] ; then
  cat <<EOF
ERROR: Please specify the password ownCloud should use to connect to the
       database!

  # docker run ... -e OC_DB_PASS=<db-pass> ...

EOF
  exit 1
fi


################################################################################
#                              CREATE CONFIGURATION
################################################################################

# Copy configuration templates if necessary.\
if [ -e "$CONFIG_DIR/autoconfig.php" ] ; then
  echo "-- Using EXISTING \`autoconfig.php'"
else
  echo "-- Using DEFAULT \`autoconfig.php'"
  cp /opt/autoconfig.php "$CONFIG_DIR"
fi

if [ -e "$CONFIG_DIR/config.php" ] ; then
  echo "-- Using EXISTING \`config.php'"
else
  echo "-- Using DEFAULT \`config.php'"
  cp /opt/config.php "$CONFIG_DIR"
fi

# Set permissions.
chown http:http "$OC_DATA_DIR"
chown -R http:http "$CONFIG_DIR"

# Generate `autoconfig.php'.
sed -ri -e "s/^(\s*\"dbtype\"\s*=>\s*).*/\1\"$OC_DB_TYPE\",/" \
        -e "s/^(\s*\"dbname\"\s*=>\s*).*/\1\"$OC_DB_NAME\",/" \
        -e "s/^(\s*\"dbuser\"\s*=>\s*).*/\1\"$OC_DB_USER\",/" \
        -e "s/^(\s*\"dbpass\"\s*=>\s*).*/\1\"$OC_DB_PASS\",/" \
        -e "s/^(\s*\"dbhost\"\s*=>\s*).*/\1\"$OC_DB_HOST\",/" \
        -e "s:^(\s*\"directory\"\s*=>\s*).*:\1\"$OC_DATA_DIR\",:" \
        "$CONFIG_DIR/autoconfig.php"


################################################################################
#                                    SUMMARY
################################################################################

cat<<EOF
================================================================================
Successfully initialised ownCloud with the following parameters!

  OC_DB_NAME=$OC_DB_NAME
  OC_DB_USER=$OC_DB_USER
  OC_DB_PASS=$OC_DB_PASS
  OC_DB_HOST=$OC_DB_HOST
  OC_DATA_DIR=$OC_DATA_DIR

================================================================================
EOF
