# Overview

This is an image containing [Supervisor][sv-hp] on [Arch Linux][al-hp]. It is
intended to be a base for images that need to run multiple processes.

Features:
- default configuration except for the features bellow
- disabled TCP socket (UNIX domain socket still enabled)
- runs in the foreground by default


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Usage

When using this image as a base for your images, just drop your program
configurations into `/etc/supervisor.d`.

```
ADD nginx.conf /etc/supervisor.d/
ADD php-fpm.conf /etc/supervisor.d/
```

Supervisor will automatically start them when the container starts up.

For a complete example see [`arch-nginx-php`][arch-nginx-php] that runs Nginx
and PHP-FPM in a single container.


<!-- References -->

[sv-hp]: http://supervisord.org/
[al-hp]: https://www.archlinux.org/
[arch-nginx-php]: ../arch-nginx
