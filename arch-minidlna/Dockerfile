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
# MariaDB on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm minidlna && rm -rf /var/cache/pacman/pkg/*

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

EXPOSE 8200/tcp 1900/udp

CMD ["/opt/start.sh"]
