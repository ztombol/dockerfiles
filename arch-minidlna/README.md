# Overview

This is an image containing [minidlna][md-hp] on [Arch Linux][al-hp].

Features:
- configurable with environment variables
- running server process under custom UID and GID
- host accessible configuration file and database


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run -d [-e MD_NAME=<name>] [-e MD_MEDIA_DIR=<media-dir>] \
             [-e MD_DB_DIR=<db-dir>] [-e MD_UID=<uid>] [-e MD_GID=<gid>] \
             -p <srv-port>:8200/tcp -p <ssdp-port>:1900/udp \
             ztombol/arch-minidlna:latest
```

Where:
- `name` - human readable name that will appear in clients, defaults to
  `media-server`
- `uid` and `gid` - User and Group ID of the account running the server
  process respectively, defaults to `nobody`'s UID and GID
- `media-dir` - sub-directory of `/data` containing the content to serve,
  defaults to `media` (i.e. `/data/media`)
- `db-dir` - sub-directory of `/data` where the database will be stored,
  defaults to `db` (i.e. `/data/db`)
- `srv-port` - host port where the server will listen
- `ssdp-port` - host port for the SSDP protocol

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

***IMPORTANT!***

*Currently docker creates container interfaces without the `MULTICAST` flag.
This means that packets of [SSDP][ssdp-wp] (the protocol minidlna uses to
announce its presence) gets filtered out, effectively hiding the server from
other devices. Work seems to be under way, see this [issue][docker-iss-mcast].
In the meanwhile there are two possible workarounds.*

* *Use [pipework][pipework-gh] to set up the container's interface.*
* *Make the container use the host's network stack by adding `--net=host` to the
  run command. This method is considered* ***insecure*** *and should be used
  for* ***debugging only***.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


## Example

This section is a step-by-step walkthrough of a typical setup. The media to be
served is already mounted under `/mnt/storage/media` on the host.

To be able to serve media from the host file system we need to mount it in the
container. We will do it through a data-only container.

The following command creates a data-only container that mounts the
`/mnt/storage/minidlna` directory of the host under `/data` in the container.
This is the directory where the configuration file will be accessible and where
the database will be stored.

```sh
# docker run --name minidlna-data \
             -v /mnt/storage/minidlna:/data \
             busybox:latest true
```

Next, let's make the media files visible to the server by *bind* mounting them
under the `media` subdirectory of the host mounted volume.

```sh
# mkdir /mnt/storage/minidlna/media
# mount --bind /mnt/storage/media /mnt/storage/minidlna/media
```

Finally, we can create the application container.

```sh
# docker run -d --name minidlna -e MD_NAME="my media server" \
             -p 8200:8200/tcp -p 1900:1900/udp \
             --volumes-from=minidlna-data \
             --net="host" \
             ztombol/arch-minidlna:latest
```

This will create and start a `minidlna` instance named `my media server` and
will automatically pick up the files stored in `/mnt/storage/minidlna/media`.

The configuration file is accessible from the host under the root of the mounted
volume. If necessary, you can edit it directly and restart the container so that
the changes take effect.


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

For example, to update the container we set up above use the following commands.

First, rebuild the image.

```sh
# ./build.sh
```

Then, save the parameters.

```sh
# MD_NAME="$(docker logs minidlna | grep "^\s*MD_NAME=" | sed -r 's/[^=]*=(.*)$/\1/')"
# MD_MEDIA_DIR="$(docker logs minidlna | grep "^\s*MD_MEDIA_DIR=" | sed -r 's/[^=]*=(.*)$/\1/')"
# MD_DB_DIR="$(docker logs minidlna | grep "^\s*MD_DB_DIR=" | sed -r 's/[^=]*=(.*)$/\1/')"
# MD_UID="$(docker logs minidlna | grep "^\s*MD_UID=" | sed -r 's/[^=]*=(.*)$/\1/')"
# MD_GID="$(docker logs minidlna | grep "^\s*MD_GID=" | sed -r 's/[^=]*=(.*)$/\1/')"
```

Next, stop, backup and remove the old container.

```sh
# docker stop minidlna
# docker export minidlna > "minidlna_$(date +%FT%H-%M-%S).backup.tar}"
# docker rm minidlna
```

Finally, create the new container and unset the variables to prevent leaking any
sensitive information.

```sh
# docker run -d --name minidlna -e MD_NAME="$MD_NAME" \
             -e MD_MEDIA_DIR="$MD_MEDIA_DIR" -e MD_DB_DIR="$MD_DB_DIR" \
             -e MD_UID="$MD_UID" -e MD_GID="$MD_GID" \
             -p 8200:8200/tcp -p 1900:1900/udp \
             --volumes-from=minidlna-data \
             --net="host" \
             ztombol/arch-minidlna:latest
# unset MD_NAME MD_MEDIA_DIR MD_DB_DIR MD_UID MD_GID
```


# Scripts

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

***WARNING!***
*For simplicity the script sets up the application container to use the host's
network stack. This is considered insecure and should not be used for other than
debugging. See the *Important* note above.*

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The start and update processes described in the examples above are easily
scriptable and has in fact already been done in `run.sh`. This flexible helper
is highly customisable using environment variables. To see all available options
check its usage.

```sh
# ./run.sh --help
```

Note, the location of the media collection to be served is highly system
dependent and making it visible for the server, e.g. with a bind mount, has not
been included in the script.

In case the script cannot create the setup that satisfies your requirements, you
are encouraged to use it as a starting point for your own script.


## Example

To create the same setup as described in the example above, use the following
command.

```sh
# HOST_DATA_DIR="/mnt/storage/minidlna" MD_NAME="my media server" ./run.sh
```

Updating the container is even simpler.

```sh
# ./run.sh
```

The script automatically extracts the necessary parameters, stops, backups,
removes and relaunches the container mounting the configuration file, database
and media files from the data-only container `minidlna-data`. Make sure to
delete the backup container when it's not needed any more.


<!-- References -->

[md-hp]: http://sourceforge.net/projects/minidlna/
[al-hp]: https://www.archlinux.org/
[ssdp-wp]: https://en.wikipedia.org/wiki/Simple_Service_Discovery_Protocol
[docker-iss-mcast]: https://github.com/dotcloud/docker/issues/3043
[pipework-gh]: https://github.com/jpetazzo/pipework
