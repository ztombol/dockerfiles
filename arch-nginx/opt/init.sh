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
# Initialise Nginx configuration.
#
# Creates document root and configuration directory if they do not exist yet.
# Sets up default index page if no domain are configured.
#

################################################################################
#                                    DEFAULTS
################################################################################

export NX_FULL_DOC_ROOT="$NX_DATA_DIR/${NX_DOC_ROOT=http}"
export NX_FULL_CONF_DIR="$NX_DATA_DIR/conf.d"


################################################################################
#                              CREATE CONFIGURATION
################################################################################

cat <<EOF
================================================================================
Initialising Nginx!
================================================================================
EOF

# Setting up directory structure.
if [ ! -d "$NX_FULL_DOC_ROOT" ] ; then
  echo "-- Creating document root \`$NX_FULL_DOC_ROOT'"
  mkdir -p "$NX_FULL_DOC_ROOT"
else
  echo "-- Document root \`$NX_FULL_DOC_ROOT' exists"
fi

if [ ! -d "$NX_FULL_CONF_DIR/" ] ; then
  echo "-- Creating config directory \`$NX_FULL_CONF_DIR'"
  mkdir -p "$NX_FULL_CONF_DIR"
else
  echo "-- Config directory \`$NX_FULL_CONF_DIR' exists"
fi

# Hook for custom setup, e.g. setting up default index page. Also useful in
# derivated images that want to add its own setup code, e.g. changing PHP's
# `open_basedir'.
/opt/init-custom.sh

# Print summary.
cat <<EOF
================================================================================
Successfully initialised Nginx with the following parameters!

  NX_DOC_ROOT=$NX_DOC_ROOT

================================================================================
EOF

exit 0
