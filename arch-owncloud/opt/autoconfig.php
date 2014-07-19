<?php
/*
 * Default settings for a new installation. These settings overwrite the
 * corresponding settings in `config.php'. For a list of available settings see
 * the ownCloud documentation [1].
 *
 * [1]: http://doc.owncloud.org/server/6.0/admin_manual/configuration/configuration_automation.html
 */
$AUTOCONFIG = array(
  "dbtype"        => "<@OC_DB_TYPE@>",
  "dbname"        => "<@OC_DB_NAME@>",
  "dbuser"        => "<@OC_DB_USER@>",
  "dbpass"        => "<@OC_DB_PASSWORD@>",
  "dbhost"        => "<@OC_DB_HOST@>",
  "directory"     => "<@OC_DATA_DIR@>",
//  "dbtableprefix" => "",
//  "adminlogin"    => "root",
//  "adminpass"     => "root-password",
);
