#
# Nginx on Arch Linux.
#

FROM ztombol/arch-supervisor:latest
MAINTAINER Zoltan Tombol <zoltan.tombol@gmail.com>

# Install packages.
RUN pacman -Sy --needed --noconfirm nginx && rm -rf /var/cache/pacman/pkg/*

# Configure Nginx.
ADD nginx/nginx.conf /etc/nginx/
RUN chown 644 /etc/nginx/nginx.conf

# Configure Supervisor.
ADD supervisord/nginx.ini /etc/supervisor.d/
RUN chown 644 /etc/supervisor.d/nginx.ini

# Add scripts.
ADD opt /opt
RUN chmod 755 /opt/*.sh

# Expose ports.
EXPOSE 80/tcp 443/tcp

ENTRYPOINT ["/usr/bin/bash"]
CMD ["/opt/start.sh"]
