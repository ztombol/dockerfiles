#!/usr/bin/bash

#
# Script updating an existing Transmission configuration.
#

# Update RPC whitelist.
/opt/rpc-whitelist.sh

# Print summary.
cat<<EOF
================================================================================
RPC whitelist updated to \`$TM_RPC_WHITELIST'!
================================================================================
EOF
