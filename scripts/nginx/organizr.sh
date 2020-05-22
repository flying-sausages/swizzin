#!/bin/bash
# ruTorrent installation and nginx configuration
# Author: flying_sausages
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

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


###################################

phpv=$(php_v_from_nginxconf)
sock="php${phpv}-fpm"

echo "Installing Nginx Config"
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

chown -R www-data:www-data /srv/organizr
systemctl reload nginx