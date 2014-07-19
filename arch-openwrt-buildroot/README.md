# Overview

This is an image for building [OpenWrt][owrt-hp] on [Arch Linux][al-hp]. All
necessary dpendencies are installed when building the image. OpenWrt source is
cloned from GIT when running the container.

Features:
- using custom `.config`
- continuing previous builds
- using (host mounted) volume for compilation
- specifying `make` options with environment variables
- using custom Git repository for downloading sources


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

A container can be created using the following command.

```sh
# docker run [-v <host-dir>:/data] \
             [-e GIT_URL=<git-url>] [-e MAKE_OPTS=<make-opts>] \
             ztombol/arch-openwrt-buildroot:latest
```

Where:
- `host-dir` - directory on the host where the sources are downloaded and
  compiled, defaults to a docker volume if not specified.
- `git-url` - Git repository from where the sources are cloned, defaults to
  `git.openwrt.org/openwrt.git` which is the repository of the development
  version. See the [OpenWrt wiki][owrt-src] for avaiable locations.
- `make-opts` - list of options passed to make when building the firmware,
  empty by default.

Running the command without optional parameters will compile the current
development version with default configuration for all supported `ar71xx`
devices and produce the same firmware images and packages as found [on the
website][owrt-dl-bb].


# Examples

Odds are that if you want to compile your own firmware you want to do so because
the precompiled firmware does not satisfy your requirements. In most cases you
will also want to compile the firmware only for one rather than all supported
routers, greatly reducing build time and resource footprint.

The following secions walk you through a typical workflow where a custom
configuration is created and then built from the latest OpenWRT source.

Using a host-mounted directory for downloading and compiling source is almost
always preferable. We will use a one in this example.


## Creating a custom configuration file

This section describes how to create your own configuration for building a
custom firmware.

Creating your configuration file depends on knowledge of your router's hardware
and your requirements. The OpenWRT wiki is the best source of information on the
hardware of [supported devices][owrt-toh].

To create a custom configuration file specify `/opt/config.sh` as the command of
the container.

```sh
$ mkdir /tmp/openwrt-buildroot
# docker run --rm -t -i -v /tmp/openwrt-buildroot:/data \
             ztombol/arch-openwrt-buildroot:latest \
             /opt/config.sh
```

This will download the source if it have not been downloaded already, and
compile and start the configuration utility.

Once the compilation finishes and the tool has started up, you can tweak the
configuration to your hearts content. When done, select `Exit`. The
configuration will be saved in `openwrt/.config` where it can be picked up
automatically when building using the contents of the directory, as done in the
next section.

***TIP:*** *To otherwise change the build process specify
`sudo -iu openwrt /usr/bin/bash` as the command of the container.*


## Building an existing configuration

This section describes how to build OpenWRT using an existing configuration.


### Providing the configuration file

Often you want to build a configuration that you have already customised to your
needs. The build script can pick up the configuration file from the following
paths in decreasing priority.

1. buildroot directory, i.e `/data/openwrt/.config`
2. data directory, i.e `/data/.config`

If you just finished creating a new configuration, it is stored the buildroot
directory where it will be automatically picked up by the build process.

If the data directory in which the configuration was created does not exist
anymore, because you want to use a configuration you created in the past or
or because it was provided to you, copy the file into the data directory while
renaming it to `.config`.

```sh
$ cp .config.tl-wr2543-v1 /tmp/openwrt-buildroot/.config
```

If the build script does not find a configuration file in the buildroot it
copies the one from the data directory. If there is no configuration there
either the build process will use the default configuration that comes with the
source.


### Building

Once the configuration file created, building the firmware is very simple. Just
create a new container mounting the same data directory that stores the
configuration file intended to be used.

```sh
# docker run --rm -t -i -v /tmp/openwrt-buildroot:/data \
             -e MAKE_OPTS='-j 5' \
             ztombol/arch-openwrt-buildroot:latest
```

The above command uses the `-j` option to increase parallelism to speed up the
build process.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

***NOTE:*** *Increasing the number of parallel jobs with `-j` can sometimes
cause [random errors][owrt-build-mp].*

***NOTE:*** *Keep in mind that depending on the configuration, building may
require [large amounts of disk space][owrt-build-req]. Compiling in RAM may
not always be possible.*

***NOTE:*** *When using a configuration file that was generated using an earlier
version of the OpenWRT source, it is possible that the configuration file became
too old to be used with the new source tree. If this is the case, the following
warning appears just after `configure` has run.

```
WARNING: your configuration is out of sync. Please run make menuconfig, oldconfig or defconfig!
```

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

After the compilation finishes, copy the firmware image to a safe place.

```sh
cp /tmp/openwrt-buildroot/openwrt/bin/ar71xx/{md5sums,openwrt-ar71xx-generic-tl-wr2543-v1-squashfs-{factory,sysupgrade}.bin} \
   ~/firmwares/
```

If you have not settled with a specific configurtaion and experimenting with
different ones, do not delete the data directory as you can reuse the source and
the already compiled binaries. This greatly reduces the time it takes to compile
the next iteration of your configuration.


## Continuing a previous build

If the compilation has been interrupted or you want to rebuild the firmware with
a slightly changed configuration, you can use the already downloaded and
compiled files instead of starting from scratch.

When the buildroot directory is not empty, the container will not attempt to
download the source again, but use the contents of the buildroot directory
without re-downloading source, cleaning build tree or copying/generating the
configuration file. If you have compiled some of the tools and packages before,
they will not be rebuilt. Thus, reusing the source and the already compiled
binaries, if any.

Following the example we started above, to use the results of the previous build
and build a new image, e.g. after changing the configuration, just mount the
data directory of the previous build.

```sh
# docker run --rm -t -i -v /tmp/openwrt-buildroot:/data \
             -e MAKE_OPTS='-j 5' \
             ztombol/arch-openwrt-buildroot:latest
```


## Custom Git repository

Sometimes you want to use a different repository to clone the source, because
you want to build a fork or a stable version of OpenWrt. This can be easily
achieved by specifying the desired repository in the `GIT_URL` environment.

For example, the following command builds *OpenWrt 12.09 Attitude Adjustment*,
the latest stable build.

```sh
# docker run -e GIT_URL='git.openwrt.org/12.09/openwrt.git \
             ztombol/arch-openwrt-buildroot:latest
```

The command above will build the latest stable release *OpenWrt 12.09 Attitude
Adjustment*.


# Alternatives

Of course it is possible to build OpenWrt directly in the host machine's
environment, and the OpenWrt wiki also contains instructions how to set up
buildroot in a virtual machine. For more on building OpenWrt see the
[appropriate section of the Wiki][owrt-build].


<!-- References -->

[owrt-hp]: http://openwrt.org/
[al-hp]: https://www.archlinux.org/
[owrt-src]: http://wiki.openwrt.org/doc/howto/buildroot.exigence#git
[owrt-dl-bb]: http://downloads.openwrt.org/snapshots/trunk/ar71xx/
[owrt-toh]: http://wiki.openwrt.org/toh/start
[owrt-build-req]: http://wiki.openwrt.org/doc/howto/build#prerequisites
[owrt-build-mp]: http://wiki.openwrt.org/doc/howto/build#building.on.multi-core.cpu
[owrt-build]: http://wiki.openwrt.org/doc/start#building.openwrt
