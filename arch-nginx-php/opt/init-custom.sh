#!/usr/bin/bash

#
# Set up default page and change `open_basedir' on `php.ini`.
#
# Depends:
#   - $NX_FULL_DOC_ROOT
#   - $NX_FULL_CONF_DIR
#

# Set up default page if there are not domains set up.
if [ -z "$(ls -A "$NX_FULL_CONF_DIR")" ] && [ -z "$(ls -A "$NX_FULL_DOC_ROOT")" ] ; then
  # Root of the default server.
  NX_FULL_DEFAULT_ROOT="$NX_FULL_DOC_ROOT/default"

  echo "-- Setting up default index page in \`$NX_FULL_DEFAULT_ROOT'"

  # Copy files to document root.
  mkdir -p "$NX_FULL_DEFAULT_ROOT"
  cp /usr/share/nginx/html/*.html "$NX_FULL_DEFAULT_ROOT"
  cp /opt/data/index.php "$NX_FULL_DEFAULT_ROOT"

  # Create configuration file.
  sed -r "s/(root\s*).*/\1${NX_FULL_DEFAULT_ROOT//\//\\/};/" \
    < /opt/data/default.conf \
    > "$NX_FULL_CONF_DIR/default.conf"
fi

# PHP settings.
echo "-- Changing \`php.ini's \`open_basedir' to \`${NX_FULL_DOC_ROOT}'"
sed -ri "s/^(\s*open_basedir\s*=\s*)/${NX_FULL_DOC_ROOT//\//\\/}/" /etc/php/php.ini
