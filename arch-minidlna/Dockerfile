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
