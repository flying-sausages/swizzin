#!/bin/bash
# organizr installation wrapper

if [[ ! -f /install/.nginx.lock ]]; then
  echo "nginx does not appear to be installed, organizr requires a webserver to function. Please install nginx first before installing this package."
  exit 1
fi

if [[ -f /tmp/.install.lock ]]; then
  export log="/root/logs/install.log"
else
  log="/root/logs/swizzin.log"
fi

bash /usr/local/bin/swizzin/nginx/organizr.sh

systemctl force-reload nginx

mkdir /srv/organizr_db -p
chown -R www-data:www-data /srv/organizr_db  

##TODO make sure this is done right
echo "Installing python requirements"
pip install requests pprint  >> $log 2>&1
echo "Bootstrapping Database"
python /etc/swizzin/scripts/organizr.setup.py  >> $log 2>&1


touch /install/.organizr.lock