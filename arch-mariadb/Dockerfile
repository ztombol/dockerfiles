#
# MariaDB on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm mariadb && rm -rf /var/cache/pacman/pkg/*

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

EXPOSE 3306

CMD ["/opt/start.sh"]
