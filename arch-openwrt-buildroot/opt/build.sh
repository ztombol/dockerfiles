#!/usr/bin/bash

#
# This script sets up the environemnt, downloads source and builds the firmware.
#
# Depends:
#   - $DATA_DIR
#

# Set environment variables.
. /opt/env.sh

# Make sure the building user has appropriate permissions on the data directory.
chown openwrt:wheel "$DATA_DIR" && chmod 755 "$DATA_DIR"

# Download source.
sudo -u openwrt -E /opt/git-clone.sh

# Start build.
sudo -u openwrt -E /opt/do-build.sh