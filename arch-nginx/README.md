# Overview

This is an image containing [Nginx][nginx-hp] on [Arch Linux][al-hp]. It can be
used to serve files from the host, dockerise web applications or as a reverse
proxy.

Features:
- configurable with environment variables
- storing domain configuration in `conf.d`
- document root and `conf.d` can be easily made host accessible


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run -d [-e NX_DOC_ROOT=<doc-root>] \
             -p <port>:80/tcp -p <ssl-port>:443/tcp \
             ztombol/arch-nginx:latest
```

Where:
- `doc-root` - web server's document root relative to `/data`, defaults to
  `http` (i.e. `/data/http`)
- `port` and `ssl-port` - host ports for HTTP and HTTPS, respectively


## Example 1 - Serving pages from the host

This section describes a typical setup where the container is used to serve
pages stored on the host by sharing the document root and configuration
directories.

Sharing data between the host and container can be done in a flexible way using
data-only containers. In this example we will use `/mnt/storage/nginx` as the
mount point on the host side.

First, let's create the data-only container. The command bellow mounts our host
directory under `/data` in the container.

```sh
# docker run --name nginx-data -v /mnt/storage/nginx:/data \
             busybox:latest true
```

Next, let's create the application container mounting the `/data` volume from
the previously set up data-only container.

```sh
# docker run -d -p 80:80/tcp -p 443:443/tcp --volumes-from=nginx-data \
             ztombol/arch-nginx:latest
```

This will launch Nginx listening on the ports 80 and 443 of the host, and
serve domains whose pages are stored in `/mnt/storage/nginx/http` and configured
in `/mnt/storage/nginx/conf.d`.

On first run, when the document root and configuration directory are empty, a
default index page will be set up. This page will not be set up on update if the
server has at least one page set up.

To add a new virtual server, copy the hosted site's files somewhere under the
document root, i.e. `/mnt/storage/nginx/http`, and drop its configuration file
in `/mnt/storage/nginx/conf.d`.

***Note*** *that configuration files have to end with `.conf` to be picked up
by the server.*

***Note*** *that the `root` of a virtual server has to be given with the
absolute path in the container, e.g. `/data/http/default`, not its path on the
host, e.g `/mnt/storage/nginx/http/default`.*


## Example 2 - Dockerising web applications

For an example on how to use this image to dockerise a web application see the
[ownCloud image][arch-owncloud]. It uses a PHP enabled image as its base, which
in turn is based on this image.


# Update

When a new version of the application or one of its dependencies become
available the container can be updated simply by rebuilding the image and
recreating the container with the same parameters. This involves the following
simple steps.

1. Rebuild the image.
2. Make a note of the current container's parameters.
3. Stop, backup and remove the container.
4. Create a new container using the parameters obtained in *step 2*.

After making sure that everything works well, you may delete the backup.


## Example

This section walks you through the steps of updating the container we set up in
the example above.

First, rebuild the image.

```sh
# ./build.sh
```

Then, save the parameters.

```sh
# NX_DOC_ROOT="$(docker logs nginx | grep "^\s*NX_DOC_ROOT=" | sed -r 's/[^=]*=(.*)$/\1/')"
```

Next, stop, backup and remove the old container.

```sh
# docker stop nginx
# docker export nginx > "nginx_$(date +%FT%H-%M-%S).backup.tar}"
# docker rm nginx
```

Finally, create the new container and unset the variables to prevent leaking any
sensitive information.

```sh
# docker run -d --name nginx -e NX_DOC_ROOT="$NX_DOC_ROOT" \
             -p 80:80/tcp -p 443:443/tcp \
             --volumes-from=nginx-data \
             ztombol/arch-nginx:latest
# unset NX_DOC_ROOT
```


# Scripts

The start and update processes described in the examples above are easily
scriptable and has in fact already been done in `run.sh`. This flexible helper
is highly customisable using environment variables. To see all available options
check its usage.

```sh
# ./run.sh --help
```

In case the script cannot create the setup that satisfies your requirements, you
are encouraged to use it as a starting point for your own script.


## Example

To create the same setup as described in the first example, use the following
command.

```sh
# HOST_DATA_DIR="/mnt/storage/nginx" ./run.sh
```

Updating the container is even simpler.

```sh
# ./run.sh
```

The script automatically extracts the necessary parameters, stops, backups,
removes and relaunches the container mounting the document root and
configuration directory from the data-only container `ngnix-data`. Make sure to
delete the backup container when it's not needed any more.


<!-- References -->

[nginx-hp]: http://nginx.org
[al-hp]: https://www.archlinux.org/
[arch-owncloud]: ../arch-owncloud
