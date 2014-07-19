# Overview

This is an image containing the client application of [MariaDB][mdb-hp] on
[Arch Linux][al-hp]. It is intended to be used to connect to *dockerised*
MariaDB instances.

Features:
- connecting to a database in a linked container
- automatic address and port recognition via linking


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run --rm -t -i --link=<db-cont>:db \
             ztombol/arch-mariadb-client:latest [<mysql-args>]
```

Where:
- `db-cont` - container running the database to connect to
- `mysql-args` - list of arguments passed directly to `mysql`, defaults to
  `--help`

By default, without specifying `<msyql-args>`, the list of available options are
shown. To define the user, password and other options, simply specify them in
`<mysql-args>` as you would normally do when running the client application
directly.

The container is stateless, therefore it can be thrown away immediately after
its use (`--rm`).


## Example

This section shows a few typical situations where this image comes in handy.

Manually setting up a fresh database instance is a common use case. At this time
there is no root password set. The following command logs into such a database
running in the `owncloud-db` container as root and gives you the interactive
`mysql` shell.

```sh
# docker run --rm -t -i --link=owncloud-db:db ztombol/arch-mariadb-client:latest \
             -u root
```

If you are like me, you script the creation and updating of your containers.
When an application uses a database it is often necessary to initialise the
database, e.g. adding a user and a database for the application. The following
command executes the contents of `owncloud.sql` on the server running in
`owncloud-db` as root.

```sh
# docker run --rm -t -i --link=ownlcoud-db:db ztombol/arch-mariadb-client:latest \
             -u root --password=<root-pw> < owncloud.sql
```


# Update

The container is completely stateless which means that it can be updated by
simply rebuilding the image.


# Script

To save you from having to type that long command every time you need a `mysql`
shell, `run.sh` scripts provides a simple front end that can be customised using
environment variables. To see all options run the command bellow.

```sh
# ./run.sh --help
```

In case the script cannot create the setup that satisfies your requirements, you
are encouraged to use it as a starting point for your own script.


## Example

This section shows how to use `run.sh` to perform the same tasks as the
examples above.

Logging into a fresh database running in the `owncloud-db` container as root.

```sh
# sudo DB_CONT=owncloud-db MC_ARGS='-u root'
```

Executing the contents of `owncloud.sql` on the server running in `owncloud-db`
as root.

```sh
# sudo DB_CONT=owncloud-db MC_ARGS='-u root --password=<root-pw> < owncloud.sql' ./run.sh
```

<!-- References -->

[mdb-hp]: https://mariadb.org/
[al-hp]: https://www.archlinux.org/
