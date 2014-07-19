# Overview

This is an image containing [Transmission][tm-hp] on [Arch Linux][al-hp].

Features:
- specifying RPC whitelist with an environment variable
- supports host-mounted config directory
- host accessible download directory and configuration file


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run -d [-e TM_RPC_WHITELIST=<whitelist>] \
             -p <port>:9091 \
             ztombol/arch-transmission:latest
```

Where:
- `whitelist` - address and address range list from where the web interface can
   be accessed, defaults to `127.0.0.1`
- `port` - host port where the web interface will be accessible


## Example

This section walks you through a typical setup where files are downloaded to the
host's file system and the web interface is accessible from the local network.
The configuration file will be made accessible from the host, because some
settings cannot be changed using the web interface.

To make downloads go to the host file system and to make the configuration file
accessible from the host, let's create a data-only container with host-mounted
volumes.

```sh
docker run --name transmission-data \
           -v "$HOST_DATA_DIR":/var/lib/transmission \
           busybox:latest true
```

Finally, let's create the application container mounting these volumes.

```sh
docker run -d --name transmission -p 9091:9091 --volumes-from=transmission-data \
           -e TM_RPC_WHITELIST='127.0.0.1,192.168.1.*' \
           ztombol/arch-transmission:latest
```


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
# TM_RPC_WHITELIST="$(docker logs transmission 2>&1 | grep "^\s*TM_RPC_WHITELIST=" | sed -r 's/[^=]*=(.*)$/\1/')"
```

Next, stop, backup and remove the old container.

```sh
# docker stop transmission
# docker export transmission > "transmission_$(date +%FT%H-%M-%S).backup.tar}"
# docker rm transmission
```

Finally, create the new container.

```sh
docker run -d --name transmission -p 9091:9091 --volumes-from=transmission-data \
           -e TM_RPC_WHITELIST="$TM_RPC_WHITELIST" \
           ztombol/arch-transmission:latest
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
# HOST_DATA_DIR=/mnt/storage/transmission TM_RPC_WHITELIST='192.168.1.*,127.0.0.1' ./run.sh
```

Updating the container is even simpler.

```sh
# ./run.sh
```

The script automatically extracts the necessary parameters, stops, backups,
removes and relaunches the container mounting volumes from the data-only
container `transmission-data`. Make sure to delete the backup container when its
not needed any more.


<!-- References -->

[tm-hp]: https://www.transmissionbt.com/
[al-hp]: https://www.archlinux.org/
