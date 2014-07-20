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
# Nginx and PHP (PHP-FPM + APCU) on Arch Linux.
#

FROM ztombol/arch-nginx:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm php-fpm php-apcu && rm -rf /var/cache/pacman/pkg/*

# Configure PHP.
ADD php/apcu.ini /etc/php/conf.d/
ADD php/mysql.ini /etc/php/conf.d/
RUN chmod 644 /etc/php/conf.d/*.ini

# Configure Nginx.
ADD nginx/php-handler.conf /etc/nginx/conf.d/
RUN chmod 644 /etc/nginx/conf.d/php-handler.conf

# Configure Supervisor.
ADD supervisord/php-fpm.ini /etc/supervisor.d/
RUN chown 644 /etc/supervisor.d/php-fpm.ini

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

# Expose ports.
EXPOSE 80/tcp 443/tcp
