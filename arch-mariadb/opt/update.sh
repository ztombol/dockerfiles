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
# Existing database found. Checking root credentials.
#

cat <<EOF
================================================================================
Existing database found in \`$MD_DATA_DIR'. Verifying password for \`root' account.
================================================================================
EOF

# Root password has to be specified by the user.
if [ "${MD_ROOT_PASS-x}" == "x" ] ; then
  cat <<EOF
================================================================================
ERROR: No root password specified!

You can find the root password in the logs of the container that previously used
the database.

  # docker logs <id|name>

Then specify it in the \`MD_ROOT_PASS' environment variable when starting the
container.

  # docker run ... -e MD_ROOT_PASS=<password> ...

================================================================================
EOF
  exit 1
fi

# Add `datadir' to configuration.
echo "-- Adding \`datadir' to /etc/mysql/my.cnf"
sed -i "s:^\[mysqld\]$:&\ndatadir = $MD_DATA_DIR:" /etc/mysql/my.cnf

# Start MariaDB.
echo '-- Starting MariaDB'
/usr/bin/mysqld --pid-file=/run/mysqld/mysqld.pid --user=mysql &
/usr/bin/mysqld-post

# Check if password is valid by stopping MariaDB.
echo '-- Stopping MariaDB'
mysqladmin -u root --password="$MD_ROOT_PASS" shutdown
if [ "$?" -ne 0 ] ; then
cat <<EOF
================================================================================
ERROR: Invalid root password!

You can find the root password in the logs of the container that previously used
the database.

  # docker logs <id|name>

================================================================================
EOF
  exit 1
fi

cat <<EOF
================================================================================
Root password valid! Using existing database with the following parameters!

  MD_DATA_DIR=$MD_DATA_DIR
  MD_ROOT_PASS=$MD_ROOT_PASS

================================================================================
EOF

exit 0
