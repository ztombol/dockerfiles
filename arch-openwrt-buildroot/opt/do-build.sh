#!/usr/bin/bash

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
