# Overview

This is a collection of Arch Linux based docker images and support files for
hosts running them.


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


<!-- References -->

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
