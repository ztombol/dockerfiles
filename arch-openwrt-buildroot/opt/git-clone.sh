#!/usr/bin/bash

#
# Clones OpenWRT source from the git repository from `git://$GIT_URL', unless
# `$BUILDROOT_DIR' already exists and is not empty.
#
# Depends:
#   - $DATA_DIR
#   - $BUILDROOT_DIR
#

################################################################################
#                                    DEFAULTS
################################################################################

GIT_URL="${GIT_URL-git.openwrt.org/openwrt.git}"  # Git repository to clone.


################################################################################
#                                      MAIN
################################################################################

# Cloning sources.
cd "$DATA_DIR"
if [ -d "$BUILDROOT_DIR" ] && [ "$(ls -A "$BUILDROOT_DIR")" ] ; then
  echo "-- Using existing source"
else
  echo "-- Cloning source from 'git://$GIT_URL'"
  git clone "git://$GIT_URL"
fi
