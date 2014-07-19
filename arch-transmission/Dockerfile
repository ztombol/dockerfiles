#
# Supervisor process manager on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm transmission-cli && \
    rm -rf /var/cache/pacman/pkg/*

# Configure Transmission.
RUN transmission-daemon -d --download-dir=/var/lib/transmission/download \
                           --incomplete-dir=/var/lib/transmission/incomplete \
                           --watch-dir=/var/lib/transmission/watch \
        &> /opt/settings.json && \
    chmod 600 /opt/settings.json
RUN chown transmission:transmission /opt/settings.json

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

EXPOSE 9091

CMD ["/opt/start.sh"]
