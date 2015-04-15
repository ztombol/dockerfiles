# Overview

This is a collection of [Arch Linux][arch-linux-hp] based [Docker][docker-gh]
images and support files for hosts running them. All licensed under the
[GNU General Public Licence version 3][local-gplv3].


# Images

All images were designed and implemented with the following features in mind.

- A container has to be easily updatable to encourage frequent updates and
  enable quick security and bug fix application, via the rolling release model
  of Arch Linux. This is achieved with scripts inside the container providing
  startup-time configuration and scripts accompanying the image harnessing this
  service to launch containers. This means that some details of containers are
  actually setup after startup and therefore cannot be found in the
  *Dockerfile*.

- Images should enable easy separation of data and application to simplify the
  update process.

- Provide scripts for creating and updating containers. Both have to be scripted
  to minimise user intervention with useful defaults while maintaining
  flexibility of the image.

- Images have to be flexible to enable deployment in a wide range of scenarios
  without modification.

All images have been developed on `x86_64` and tested on `i686` using [this
`i386` port][ztombol-docker-i386] of docker.

List of images:
- [Arch Linux base image][arch-base]
- [Supervisor][arch-supervisor]
- [MariaDB][arch-mariadb]
- [MariaDB `mysql` client][arch-mariadb-client]
- [Nginx][arch-nginx]
- [Nginx + PHP][arch-nginx-php]
- [ownCloud][arch-owncloud]
- [OpenWRT buildroot][arch-openwrt-buildroot]
- [MiniDLNA, aka ReadyMedia][arch-minidlna]
- [Transmission][arch-transmission]


# For hosts

A collection of files intended to be used on hosts running docker, e.g. service
files for `systemd` integration.


# Licence

This project is licensed under [GPLv3][local-gplv3]. Contribution of any kind is
welcome. If you find any bugs or have suggestions, open an issue or a pull
request on the project's [GitHub page][dockerfiles-gh].

The following assets were derived from other projects.

- [`mkimage-arch.sh`][mk-arch] and [`mkimage-arch-pacman.conf`][mk-arch-conf],
  the script and configuration file generating an Arch Linux root filesystem,
  are based on files from [Docker][docker-gh]. The originals are licensed under
  Apache 2.0, while the derived files are covered by [GPLv3][local-gplv3].
  Docker's [licence][docker-licence] and [attribute notice][docker-notice] are
  included in the directory of the derived files.

***NOTE:*** *For brevity, copyright notices use ranges to specify years in which
the copyright is valid. A range ("2014-2016") means that every year,
inclusively, is a "copyrightable" year that would be listed individually ("2014,
2015, 2016").*


<!-- References -->

[arch-linux-hp]: https://archlinux.org
[docker-gh]: https://github.com/dotcloud/docker
[local-gplv3]: COPYING
[dockerfiles-gh]: https://github.com/ztombol/dockerfiles
[mk-arch]: arch-base/mkimage-arch.sh
[mk-arch-conf]: arch-base/mkimage-arch-pacman.conf
[docker-licence]: arch-base/Docker-LICENCE
[docker-notice]: arch-base/Docker-NOTICE

[ztombol-docker-i386]: https://github.com/ztombol/docker/tree/feat-386-support
[arch-base]: arch-base
[arch-mariadb]: arch-mariadb
[arch-mariadb-client]: arch-mariadb-client
[arch-minidlna]: arch-minidlna
[arch-nginx]: arch-nginx
[arch-nginx-php]: arch-nginx-php
[arch-openwrt-buildroot]: arch-openwrt-buildroot
[arch-owncloud]: arch-owncloud
[arch-supervisor]: arch-supervisor
[arch-transmission]: arch-transmission
