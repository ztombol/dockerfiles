# Overview

This is an [Arch Linux][al-hp] base image. The root file system is generated
using the `mkimage-arch.sh` script [provided with docker][docker-mkimage].


# Build

To build the image, first generate a new root file system, then invoke
`./build.sh` as shown bellow.

```shell
# ./mkimage-arch.sh
# ./build.sh
```

Alternatively, if you do not have access to an Arch Linux installation, you can
use the root file system provided in this repository.

```shell
$ ln -s "$(ls | grep "archlinux-$(uname -m)-[0-9-]\{10\}.tar.xz" | tail -n 1)" archlinux-rootfs.tar.xz
# ./build.sh
```


<!-- References -->

[al-hp]: https://www.archlinux.org/
[docker-mkimage]: https://github.com/dotcloud/docker/blob/master/contrib/mkimage-arch.sh
