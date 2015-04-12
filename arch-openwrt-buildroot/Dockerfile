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
