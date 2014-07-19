#!/usr/bin/bash

#
# Update database address (it may differ after restarting containers).
#

# Update database address
OC_DB_HOST="$(echo $DB_PORT | sed -r 's;^[^:]+://;;')"

sed -ri "s/^(\s*'dbhost'\s*=>\s*')[^']*(',.*)/\1$OC_DB_HOST\2/" \
  "$CONFIG_DIR/config.php"

# Print summary.
cat<<EOF
================================================================================
Database address updated to \`$OC_DB_HOST'!
================================================================================
EOF
