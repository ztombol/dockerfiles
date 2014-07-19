# Overview

This is an image containing [Nginx][nginx-hp] with PHP ([PHP-FPM][php-fpm-hp]
and [APCu][php-apcu-hp]) on [Arch Linux][al-hp]. It can be used to serve files
from the host or dockerise web applications.

Features:
- configurable with environment variables
- storing domain configuration in `conf.d`
- document root and `conf.d` can be easily made host accessible
- PHP execution restricted to files under document root
- MySql support in PHP enabled by default

Usage and behaviour is identical to that of [arch-nginx][arch-nginx].


<!-- References -->

[nginx-hp]: http://nginx.org
[php-fpm-hp]: https://php.net/manual/en/install.fpm.php
[php-apcu-hp]: http://pecl.php.net/package/APCu
[al-hp]: https://www.archlinux.org/
[arch-nginx]: ../arch-nginx
