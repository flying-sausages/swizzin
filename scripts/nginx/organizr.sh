#!/bin/bash
# ruTorrent installation and nginx configuration
# Author: flying_sausages
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

if [[ ! -f /install/.nginx.lock ]]; then
  echo "nginx does not appear to be installed, ruTorrent requires a webserver to function. Please install nginx first before installing this package."
  exit 1
fi

. /etc/swizzin/sources/functions/php
phpversion=$(php_service_version)

if [[ $phpversion == '7.0' ]]; then 
  echo "Your version of PHP is too old for Organizr"
  exit 1
fi

users=($(cut -d: -f1 < /etc/htpasswd))

export DEBIAN_FRONTEND=noninteractive

echo "Fetching Updates"
apt-get update -y -q >> $log 2>&1
echo "Installing dependencies"
apt-get install -y -q php-mysql php-sqlite3 sqlite3 php-xml php-zip openssl php-curl >> $log 2>&1


if [[ ! -d /srv/organizr ]]; then
  git clone https://github.com/causefx/Organizr /srv/organizr >> $log 2>&1
  chown -R www-data:www-data /srv/organizr
fi

phpv=$(php_v_from_nginxconf)
sock="php${phpv}-fpm"

if [[ ! -f /etc/nginx/apps/organizr.conf ]]; then
cat > /etc/nginx/apps/organizr.conf <<RUM
location /organizr {
  alias /srv/organizr;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd;

  location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/$sock.sock;
    fastcgi_param SCRIPT_FILENAME /srv\$fastcgi_script_name;
  }
}
RUM
fi

. /etc/swizzin/sources/functions/php
restart_php_fpm

chown -R www-data:www-data /srv/organizr
systemctl reload nginx
touch /install/.organizr.lock
