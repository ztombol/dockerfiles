#
# MariaDB client on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm mariadb-clients && rm -rf /var/cache/pacman/pkg/*

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

ENTRYPOINT ["/opt/start.sh"]
CMD ["--help"]
