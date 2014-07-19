#
# Supervisor on Arch Linux.
#

FROM ztombol/arch-base:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm supervisor && rm -rf /var/cache/pacman/pkg/*

# Configure Supervisor.
ADD supervisord.conf /etc/
RUN chmod 600 /etc/supervisord.conf

# Run Supervisor when the container starts up.
ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-c", "/etc/supervisord.conf"]
