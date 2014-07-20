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
# No existing database found. Initialise new database.
#

cat <<EOF
================================================================================
Initialising MariaDB in \`$MD_DATA_DIR' with \
$([ "${MD_ROOT_PASS-x}" == "x" ] && echo RANDOM || echo PRESET) \
password for the \`root' account.
================================================================================
EOF

# Generate `root' password if not specified by user.
MD_ROOT_PASS="${MD_ROOT_PASS-$(cat /dev/urandom | tr -cd [:alnum:] | fold -w 64 | head -n 1)}"

# Add `datadir' to configuration.
# NOTE: The parameter expansion at the end of the rule escapes slashes in the
#       path to prevent them from interfering with sed's separators.
echo "-- Adding \`datadir' to /etc/mysql/my.cnf"
sed -i "s/^\[mysqld\]$/&\ndatadir = ${MD_DATA_DIR//\//\\/}/" /etc/mysql/my.cnf

# Copy database files into the data container.
if [ "$(df --output=fstype "$MD_DATA_DIR" | tail -n 1)" == "btrfs" ] ; then
  echo "-- $MD_DATA_DIR is on btrfs, turning off COW"
  chattr +C "$MD_DATA_DIR"
fi
echo "-- Copying database files to $MD_DATA_DIR"
cp -a /var/lib/mysql/* "$MD_DATA_DIR"
chown mysql:mysql "$MD_DATA_DIR" && chmod 700 "$MD_DATA_DIR"

# Start MariaDB.
echo '-- Starting MariaDB'
/usr/bin/mysqld --pid-file=/run/mysqld/mysqld.pid --user=mysql &
/usr/bin/mysqld-post

# Customise installation.
echo '-- Hardening security (setting root password, removing anonymous access, etc.)'
/usr/bin/mysql --user=root <<EOF
  #
  # Steps from 'mysql_secure_installation'.
  #
  
  # Set the root password.
  UPDATE mysql.user SET Password=PASSWORD('$MD_ROOT_PASS') WHERE User='root';

  # Remove anonymous users.
  DELETE FROM mysql.user WHERE User='';

  # Disallow root login remotely.
  #
  # NOTE:
  #   This deletes 'root'@'$(hostname)' as well. Which is good because the
  #   hostname will be different after using the database from a different
  #   container, e.g. after updating the image and relaunching the container.
  #
  #   The remote access is added back in bellow.
  #
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

  # Remove test database and access to it.
  DROP DATABASE test; DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

  # Reload privilege tables.
  FLUSH PRIVILEGES;


  #
  # Additional steps.
  #

  #
  # Allow remote access from other containers.
  #
  # NOTE:
  #   The IP address is hardcoded and may varry in your case.
  CREATE USER 'root'@'172.17.%' IDENTIFIED BY '$MD_ROOT_PASS';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.17.%' WITH GRANT OPTION;
  #GRANT PROXY ON ''@'' TO 'root'@'172.17.%' WITH GRANT OPTION;
EOF

# Stop MariaDB.
echo '-- Stopping MariaDB'
mysqladmin -u root --password="$MD_ROOT_PASS" shutdown

# Print summary.
cat <<EOF
================================================================================
Successfully initialised MariaDB with the following parameters!

  MD_DATA_DIR=$MD_DATA_DIR
  MD_ROOT_PASS=$MD_ROOT_PASS

================================================================================
EOF

exit 0
