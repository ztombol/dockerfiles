#
# Copyright (C)  2013  Zoltan Vass <zoltan (dot) tombol (at) gmail (dot) com>
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
# Owncloud 6 hosted with Nginx and PHP installed on Arch Linux.
#

FROM ztombol/arch-nginx-php:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm owncloud php-mcrypt php-ldap exiv2 && \
    rm -rf /var/cache/pacman/pkg/*

# Configure PHP.
ADD php/owncloud.ini /etc/php/conf.d/
RUN chmod 644 /etc/php/conf.d/owncloud.ini

# Configure Nginx.
ADD nginx/owncloud.conf /etc/nginx/conf.d/
RUN chown 644 /etc/nginx/conf.d/owncloud.conf

# Configure ownCloud.
RUN chown -R http:http /usr/share/webapps/owncloud && \
    rm -r /usr/share/webapps/owncloud/config

# Fix "Can't write into config directory!" by moving the config directory back
# to its original place, instead of using a symlink to `/etc/webapps/owncloud/config'.
RUN rm -r /etc/webapps

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh && \
    chmod 600 /opt/*.php && \
    chown http:http /opt/*.php
RUN rm /opt/init-custom.sh

#CMD ["/opt/start.sh"]
