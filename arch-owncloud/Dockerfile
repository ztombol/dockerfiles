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
