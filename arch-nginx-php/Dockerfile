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
