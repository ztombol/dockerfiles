#!/usr/bin/bash

#
# Updates the RPC whitelist in `settings.json'.
#
# Depends:
#   - $TM_CONFIG_DIR
#   - $TM_RPC_WHITELIST
#

################################################################################
#                                      MAIN
################################################################################

# Update RPC whitelist.
sed -ri "s/^(\s*\"rpc-whitelist\":\s*).*/\1\"$TM_RPC_WHITELIST\",/" \
  "$TM_CONFIG_DIR/settings.json"
