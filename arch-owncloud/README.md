# Overview

This is an image containing [ownCloud][oc-hp] on [Arch Linux][al-hp].

Features:
- configurable with environment variables
- using database of a linked container
- automatic configuration file generation
- enabling SSL by default
- 16GiB maximum upload size


# Build

Use the provided build script to build the image.

```sh
# ./build.sh
```


# Run

After [setting up the database](#mariadb), a container can be created using the
following command.

```sh
# docker run -d [-e OC_DB_NAME=<db-name>] [-e OC_DB_USER=<db-user>] \
             [-e OC_DATA_DIR=<data-dir>] \
             -e OC_DB_PASS=<db-pass> \
             --link=<db-cont>:db -p <port>:80 -p <ssl-port>:443 \
             ztombol/arch-owncloud:latest
```


Where:
- `db-name` - name of the database to use, defaults to `owncloud`
- `db-user` and `db-pass` - credentials used to authenticate against the
  database, user name defaults to `owncloud` and password is mandatory
- `data-dir` - directory where the files will be stored in the container,
  defaults to `/usr/share/webapps/owncloud/data`
- `db-cont` - name of the container running the database to use
- `port` and `ssl-port` - host ports for HTTP and HTTPS, respectively


## Example

This section describes a typical setup where uploaded files are stored on the
host's file system and the database service is provided by another container.


### Mariadb

Before creating an ownCloud instance we need to set up its database. This
example uses the [MariaDB server][arch-mariadb] and [client]
[arch-mariadb-client] images provided in this repository.

***NOTE:*** *The image currently supports MySQL and MariaDB. If you want to use
other database servers you need to configure PHP, and set the database type in
ownCloud's configuration.*

First, let's create the database and its data container.

```sh
# docker run -v /data --name owncloud-db-data busybox:latest true
# docker run -d --volumes-from=owncloud-db-data \
             --name owncloud-db ztombol/arch-mariadb:latest
```

You can also use the `run.sh` script provided with the [MariaDB server image]
[arch-mariadb].

```sh
# APP_NAME=owncloud-db ./run.sh
```

Either way, the commands will result in a database instance running in
`owncloud-db` which stores its data in `owncloud-db-data`, and whose root
account is protected with a random password.

Next, we need to create a user and a database for ownCloud. The following
commands will accomplish that using the [MariaDB client][arch-mariadb-client]
image, but you can use any client.

```sh
# DB_ROOT_PASS="$(sudo docker logs owncloud-db 2>/dev/null \
    | grep 'ROOT_PASS=' | sed -r 's/^\s*ROOT_PASS=(.*)$/\1/')"
# OC_DB_PASS=$(cat /dev/urandom | tr -cd [:alnum:] | fold -w 64 | head -n 1)
# docker run --rm -t -i --link=owncloud-db:db \
             ztombol/arch-mariadb-client:latest \
             -uroot --password="$DB_ROOT_PASS" \
    <<EOF
      CREATE DATABASE owncloud DEFAULT CHARSET utf8;
      CREATE USER 'owncloud'@'%' IDENTIFIED BY '$OC_DB_PASS';
      GRANT ALL PRIVILEGES ON owncloud.* TO 'owncloud'@'%';
      FLUSH PRIVILEGES;
      EXIT
EOF
# unset DB_ROOT_PASS
```

At this point we have a database and a user with a randomly generated password
for ownCloud to use. Continue with the next section to see how to set up the
web side of the installation.


### Owncloud

After successfully setting up the database for ownCloud, we can proceed with the
web server.

As before with the database, we will use a data-only container to separate data
and application.

First, let's create the data-only container. The following command sets up the
container and mounts the `data`, `config` and `ssl` directories on the host.

```sh
# docker run --name owncloud-data \
             -v /mnt/storage/owncloud/data:/usr/share/webapps/owncloud/data \
             -v /mnt/storage/owncloud/config:/usr/share/webapps/owncloud/config \
             -v /mnt/storage/owncloud/certs:/etc/nginx/ssl \
             busybox:latest true
```

This will make ownCloud store uploaded files on the host's file system, and make
the configuration file and certificates easily accessible in case they need to
be changed.

Next, copy the SSL certificate and key to the `certs` sub-directory. Don't
forget to set appropriate ownership (e.g. `root:root`) and permissions on them.

```sh
# cp owncloud.crt /mnt/storage/owncloud/certs/owncloud.crt
# chmod 644 /mnt/storage/owncloud/certs/owncloud.crt
# cp owncloud.key /mnt/storage/owncloud/certs/owncloud.key
# chmod 600 /mnt/storage/owncloud/certs/owncloud.key
```

It is important to name the certificate and the key `owncloud.crt` and
`owncloud.key`, respectively.

Then, create the application container. Note, that the password we generated for
ownCloud during database setup has to be passed to this container in
`$OC_DB_PASS` to allow it to automatically generate the configuration file.

```sh
# docker run -d --name owncloud \
             -e OC_DB_PASS="$OC_DB_PASS" \
             --link=owncloud-db:db -p 80:80/tcp -p 443:443/tcp \
             --volumes-from=owncloud-data \
             ztombol/arch-owncloud:latest
```

Finally, point your browser to the address of the server and create the admin
user as instructed. At this point the installation is complete and you may begin
using ownCloud.

*This image uses [Automatic configuration][oc-auto-conf] to configure ownCloud
(setting database credentials and host, etc.). That's why you only need to
create an administrator user without setting up database details.*


# Update

When a new version of the application or one of its dependencies become
available the container can be updated simply by rebuilding the image and
recreating the container with the same parameters. This involves the following
simple steps.

1. Rebuild the image.
2. Stop, backup and remove the container.
3. Create a new container using the parameters obtained in *step 2*.

After making sure that everything works well, you may delete the backup.

***NOTE:*** *You do not need to save the parameters from the container log as
with other images in this repository, because all parameters passed to the
container when first created get written to the configuration file in the host
mounted `config` directory.*


## Example

For example, to update the container we set up above use the following commands.

First, rebuild the image.

```sh
# ./build.sh
```

Then, stop, backup and remove the old container.

```sh
# docker stop owncloud
# docker export owncloud > "owncloud_$(date +%FT%H-%M-%S).backup.tar}"
# docker rm owncloud
```

Finally, create the new container while making sure to link and mount the same
database and data containers as before.

```sh
# docker run -d --name owncloud \
             --link=owncloud-db:db -p 80:80/tcp -p 443:443/tcp \
             --volumes-from=owncloud-data \
             ztombol/arch-owncloud:latest
```


# Under the hood

When the container is started for the first time the configuration files are
prepared. `opt/start.sh` interpolates and copies `autoconfig.php` to the
configuration directory along with `config.php`.
[Automatic configuration][oc-auto-conf] configures the database access and data
path details when the first web request arrives.

If you want to customise the default installation edit `config.php`. It will be
added to the image along with `autoconfig.php` and its settings will be updated
by the ones found in `autoconfig.php`. 

When a container is stopped and then started again it is not guaranteed to have
the same IP address. Therefore, this image takes care to update `DB_HOST` in
`config.php`.


## Disabling SSL

***Warning!*** *The importance of SSL can never be overstated. You should never
run a production system without SSL. Instructions on how to disable SSL is only
provided for debugging puporses.*

You can disable SSL by commenting out the 14 lines in ownCloud's Nginx
configuration as shown bellow, rebuilding the image and starting a new
container.

```
server {
    # Enforce SSL
    listen 80;
#    return 301 https://$host$request_uri;
#}
#
#server {
#    listen 443 ssl;
#
#    ssl_certificate     /etc/nginx/ssl/owncloud.crt;
#    ssl_certificate_key /etc/nginx/ssl/owncloud.key;
#
#    ssl_protocols         TLSv1.2;
#    ssl_ciphers           EDH+AESGCM;
#    ssl_prefer_server_ciphers off;
#    ssl_session_cache     shared:SSL:256k;
#    ssl_session_timeout       10m;
    
     # Path to the root of your installation
     root /usr/share/webapps/owncloud;
     ...
```


<!-- References -->

[oc-hp]: https://owncloud.org/
[al-hp]: https://www.archlinux.org/
[oc-auto-conf]: http://doc.owncloud.org/server/6.0/admin_manual/configuration/configuration_automation.html
[arch-mariadb]: ../arch-mariadb
[arch-mariadb-client]: ../arch-mariadb-client
