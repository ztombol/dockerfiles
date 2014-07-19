# Overview

This is an image containing [MariaDB][mdb-hp] on [Arch Linux][al-hp]. It can be
used to provide database service for other images.

Features:
- storing database files at user specified path
- [disabling copy-on-write][aw-mdb-cow] for `btrfs` data directory
- random or user specified root password
- performing steps of `mysql_secure_installation` with default (secure)
  choices except for root access (see bellow)
- allowing root access from other containers (currently hardcoded as 172.17.*.*)


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run -d [-e MD_DATA_DIR=<data-dir>] [-e MD_ROOT_PASS=<root-pw>] \
             [-p <port>:3306] \
             ztombol/arch-mariadb:latest
```

Where:
- `data-dir` - location where the database will be stored in the container,
  defaults to `/data`
- `root-pw` - password of the root account, defaults to a 64 character
  alphanumeric random string
- `port` - host port where the server will listen, necessary when the client is
  not in a linked container


## Example

This section is a step-by-step walkthrough of a typical setup in which data and
application are separated into distinct containers.

First, lets create the data-only container where the database files will be
stored.

```sh
# docker run -v /data --name mariadb-data busybox:latest true
```

Then, we can create the application container.

```sh
# docker run -d --volumes-from=mariadb-data \
             --name mariadb ztombol/arch-mariadb:latest
```

This will create and start a database instance running in `mariadb` and storing
its databases in the data-only `mariadb-data` container. This decoupling of
application and data enables easy application updates.

In this example the root account password was left unspecified, causing the
container to generate it randomly. A random generated password can be obtained
from the log of the container.

```sh
# docker logs mariadb
...
================================================================================
Successfully initialised MariaDB with the following parameters!

  MD_DATA_DIR=/data
  MD_ROOT_PASS=8YHmNtVd6CyAmPYy18AVqRNs7yr3sMJz23bYxszvq80tVgSMIpeDzkAgYVq5bKCE

================================================================================
...
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
***Note on Security***

*Depending on your security model, leaving the database root password
recoverable by system administrators may be a security and/or legal risk.*

*The same users (superuser, sudo users and docker group members) who can access
the container logs and inspect containers and thus obtain the database root
password can stop and delete the database and its data container.*

*Ask yourself whether it is acceptable to store the password within the reach of
these users.*
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


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

While the password is not necessary to update a container, it is used to echo it
into the new container's log as a safety net against losing it during updates.
This way the root password can always be found in the log of the currently
running container, and does not get lost when the administrator fails to make
note of it before deleting the original container.


## Example

For example, to update the container we set up above use the following commands.

First, rebuild the image.

```sh
# ./build.sh
```

Then, save the parameters.

```sh
# MD_DATA_DIR="$(docker logs mariadb | grep "^\s*MD_DATA_DIR=" | sed -r 's/[^=]*=(.*)$/\1/')"
# MD_ROOT_PASS="$(docker logs mariadb | grep "^\s*MD_ROOT_PASS=" | sed -r 's/[^=]*=(.*)$/\1/')"
```

Next, stop, backup and remove the old container.

```sh
# docker stop mariadb
# docker export mariadb > "mariadb_$(date +%FT%H-%M-%S).backup.tar}"
# docker rm mariadb
```

Finally, create the new container and unset the variables to prevent leaking the
root password.

```sh
# docker run -d --name mariadb --volumes-from=mariadb-data \
             -e MD_DATA_DIR="$MD_DATA_DIR" -e MD_ROOT_PASS="$MD_ROOT_PASS" \
             ztombol/arch-mariadb:latest
# unset MD_ROOT_PASS MD_DATA_DIR
```


# Scripts

The start and update processes described in the above examples are easily
scriptable and has in fact already been scripted in `run.sh`. This flexible
helper is highly customisable using environment variables. To see all available
options check its usage.

```sh
# ./run.sh --help
```

In case the script cannot create the setup that satisfies your requirements, you
are encouraged to use it as a starting point for your own script.


# Example

To create the same setup as described in the example above, use the following
command.

```sh
# APP_NAME=mariadb ./run.sh
```

Updating the container is even simpler.

```sh
# ./run.sh
```

The script automatically extracts the necessary parameters, stops, backups,
removes and relaunches the container mounting database files from the data-only
container `mariadb-data`. Make sure to delete the backup container when its not
needed any more.


<!-- References -->

[mdb-hp]: https://mariadb.org/
[al-hp]: https://www.archlinux.org/
[aw-mdb-cow]: https://wiki.archlinux.org/index.php/MariaDB#Installation
