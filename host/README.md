# Overview

This is a collection of files intended to be used on hosts running docker.
Currently the only supported feature is systemd integration.


# systemd integration

To [integrate docker with systemd][docker-host-int] and to be able to handle
containers using systemd, we need the following two service files.

`docker.service` disables restarting previously running container after a daemon
restart (systemd will take care of this) and allows inter-container
communication only between linked containers. The latter one is not necessary
for systemd integration, but greatly improves security.

`docker@.service` is a service template representing an arbitrary container
named after the `@`. For more information on service templates files see
*systemd.unit (5)*.


## Setup

Copy both files to systemd's *local configuration* directory.

```sh
# cp docker{,@}.service /etc/systemd/system
```


## Usage

Handling of containers through systemd is identical to handling other services.

For example to start and enable a container named `owncloud` execute the
following commands.

```sh
# systemctl start docker@owncloud.service
# systemctl enable docker@owncloud.service
```

After enabling a container systemd will make sure that the container is started
on boot.

To stop and disable the same container use the following commands.

```sh
# systemctl stop docker@owncloud.service
# systemctl disable docker@owncloud.service
```

The output of containers will go to the host's journal.


<!-- References -->

[docker-host-int]: https://docs.docker.com/articles/host_integration/
