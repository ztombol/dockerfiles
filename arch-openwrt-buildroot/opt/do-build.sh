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
# This script handles the configuration file and builds the firmwares.
#

################################################################################
#                                    DEFAULTS
################################################################################

DATA_DIR='/data'                  # Data directory.
MAKE_OPTS="${MAKE_OPTS-}"         # Options passed to `make', e.g. `-j 5'.


################################################################################
#                                      MAIN
################################################################################

# Use user-supplied configuration if exists, default otherwise. 
cd "$BUILDROOT_DIR"
if [ ! -f "$BUILDROOT_DIR/.config" ] ; then
  if [ -f "$DATA_DIR/.config" ] ; then
    echo '-- Using user supplied configuration file'
    cp "$DATA_DIR/.config" .
  else
    echo '-- Using default configuration file'
    make defconfig
  fi
else
  echo '-- Using existing configuration file'
fi

# Build.
echo '-- Starting build process'
time make $MAKE_OPTS
