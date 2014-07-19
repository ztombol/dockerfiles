#!/usr/bin/bash

#
# This script build OpenWRT. This setup uses a host-mounted volume to download
# and compile sources.
#


################################################################################
#                                   PARAMETERS
################################################################################

APP_NAME="${APP_NAME:-openwrt}"           # Application container name.
HOST_DATA_DIR="${HOST_DATA_DIR:-$(pwd)/openwrt-buildroot}"
                                          # Directory of host mounted volume.


################################################################################
#                                     USAGE
################################################################################

if [ "$#" != "0" ] ; then
  cat <<EOF
USAGE:
  $0 [args...]

ARGUMENTS:
  Presence of any argument causes the script to display this help and exit.

ENVIRONMENT:
  In addition to the variables listed bellow, all environment variables
  supported by the container (supplied to run via \`-e') can be used here.

  APP_NAME       Application container name [$APP_NAME]
  HOST_DATA_DIR  Directory of host mounted volume [\$(pwd)/openwrt-buildroot]
EOF
  exit 0
fi


################################################################################
#                                      MAIN
################################################################################

# Make sure we are running as root.
if [ "$EUID" -ne 0 ] ; then
    echo 'This script must be run as root.' 1>&2
    exit 1
fi

# Application container.
echo "-- Creating new OpenWRT buildroot container"
docker run --rm -t -i --volume=$HOST_DATA_DIR:/data \
           ztombol/arch-openwrt-buildroot:latest
