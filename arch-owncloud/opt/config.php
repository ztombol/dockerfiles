<?php
/*
 * Default settings for a new installation. Settings in `autoconfig.php'
 * overwrite the corresponding settings here. For a list of avaialble settings
 * see the ownCloud documentation [1].
 *
 * [1]: http://doc.owncloud.org/server/6.0/admin_manual/config/index.html.
 */
$CONFIG = array (
/*
  'trusted_domains' =>
  array (
    0 => 'owncloud.mydomain',
  ),
*/

  // Skip checking webdav. It always reports error.
  'check_for_working_webdav' => false,
);
