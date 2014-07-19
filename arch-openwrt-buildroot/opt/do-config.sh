#!/usr/bin/bash

#
# This script compiles and starts the configuration utility.
#
# Depends:
#   - $DATA_DIR
#   - $BUILDROOT_DIR
#

# Compile and start menuconfig.
echo "-- Compiling menuconfig"
cd "$BUILDROOT_DIR"
make menuconfig
