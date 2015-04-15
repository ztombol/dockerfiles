#!/usr/bin/env bash

#
# This file (GPLv3 licensed) is based on `contrib/mkimage-arch.sh' (Apache 2.0
# licensed) from the Docker project [1]. A copy of Docker's licence [2] and
# attribution notice [3] is included in `Docker-LICENCE' and `Docker-NOTICE'
# respectively.
#
# [1]: https://github.com/docker/docker
# [2]: https://raw.githubusercontent.com/docker/docker/master/LICENSE
# [3]: https://raw.githubusercontent.com/docker/docker/master/NOTICE
#

#
# Copyright (C)  2014  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
#
# This file is part of Dockerfiles.
#
# Dockerfiles is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Dockerfiles is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Dockerfiles.  If not, see <http://www.gnu.org/licenses/>.
#


#
# Generate a minimal filesystem for archlinux. Requires root.
#
set -e

hash pacstrap &>/dev/null || {
    echo "Could not find pacstrap. Run pacman -S arch-install-scripts"
    exit 1
}

hash expect &>/dev/null || {
    echo "Could not find expect. Run pacman -S expect"
    exit 1
}

ROOTFS=$(mktemp -d ${TMPDIR:-/var/tmp}/rootfs-archlinux-XXXXXXXXXX)
chmod 755 $ROOTFS

# packages to ignore for space savings
PKGIGNORE=linux,jfsutils,lvm2,cryptsetup,groff,man-db,man-pages,mdadm,pciutils,pcmciautils,reiserfsprogs,s-nail,xfsprogs

expect <<EOF
  set send_slow {1 .1}
  proc send {ignore arg} {
    sleep .1
    exp_send -s -- \$arg
  }

  set timeout 60
  spawn pacstrap -C ./mkimage-arch-pacman.conf -c -d -G -i $ROOTFS base haveged --ignore $PKGIGNORE
  expect {
    -exact "anyway? \[Y/n\] " { send -- "n\r"; exp_continue }
    -exact "(default=all): " { send -- "\r"; exp_continue }
    -exact "installation? \[Y/n\]" { send -- "y\r"; exp_continue }
  }
EOF

arch-chroot $ROOTFS /bin/sh -c "haveged -w 1024; pacman-key --init; pkill haveged; pacman -Rs --noconfirm haveged; pacman-key --populate archlinux"
arch-chroot $ROOTFS /bin/sh -c "ln -s /usr/share/zoneinfo/UTC /etc/localtime"
echo 'en_US.UTF-8 UTF-8' > $ROOTFS/etc/locale.gen
arch-chroot $ROOTFS locale-gen
arch-chroot $ROOTFS /bin/sh -c 'echo "Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist'

# udev doesn't work in containers, rebuild /dev
DEV=$ROOTFS/dev
rm -rf $DEV
mkdir -p $DEV
mknod -m 666 $DEV/null c 1 3
mknod -m 666 $DEV/zero c 1 5
mknod -m 666 $DEV/random c 1 8
mknod -m 666 $DEV/urandom c 1 9
mkdir -m 755 $DEV/pts
mkdir -m 1777 $DEV/shm
mknod -m 666 $DEV/tty c 5 0
mknod -m 600 $DEV/console c 5 1
mknod -m 666 $DEV/tty0 c 4 0
mknod -m 666 $DEV/full c 1 7
mknod -m 600 $DEV/initctl p
mknod -m 666 $DEV/ptmx c 5 2
ln -sf /proc/self/fd $DEV/fd

echo '==> Compressing file system...'
ARCHIVE_NAME="archlinux-$(uname -m)-$(date -u +%F_%H-%M-%S%z).tar.xz"
tar --numeric-owner -C $ROOTFS -caf "$ARCHIVE_NAME" .
rm -rf $ROOTFS

# Create a symlink for ./build.sh.
rm -f archlinux-rootfs.tar.xz
ln -s "$ARCHIVE_NAME" archlinux-rootfs.tar.xz
