#!/usr/bin/bash

#
# Update ownCloud configuration after updating the container.
#

# Version number.
OC_VERSION="$(grep '^\$OC_Version = array(.*);$' "$APP_DIR/version.php" | \
  sed -r -e 's/^\$OC_Version\s*=\s*array\((.*)\);$/\1/' -e 's/,/./g')"

if [ "${OC_VERSION:-x}" == x ] ; then
  cat<<EOF
================================================================================
ERROR: Cannot determine the version number of ownCloud!
================================================================================
EOF
  exit 1
fi

sed -ri "s/^(\s*'version'\s*=>\s*')[^']*(',.*)/\1$OC_VERSION\2/" \
  "$CONFIG_DIR/config.php"

# Print summary.
cat<<EOF
================================================================================
Successfully updated the following parameters in \`config.php'!

  version => $OC_VERSION

================================================================================
EOF

exit 0
