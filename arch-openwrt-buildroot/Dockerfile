#
# OpenWRT buildroot on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm sudo base-devel svn git unzip python2 wget && \
    rm -rf /var/cache/pacman/pkg/*

# Create new user.
RUN useradd -g wheel -d /data -s /bin/bash openwrt && \
    sed -ri 's/^# (%wheel ALL=(ALL) NOPASSWD: ALL)$/\1/' /etc/sudoers

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

VOLUME ["/data"]
CMD ["/opt/build.sh"]
