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

echo "Setting up the organizr database"
curl -X POST \
--data-urlencode "path=/srv/organizr"\
--data-urlencode "formKey=" \
-H "Content-Type: application/x-www-form-urlencoded" \
--user test:test \
-k \
https://localhost/organizr/api/?v1/wizard_path \
| python -m json.tool >> $log 2>&1

#These are hardcoded for testing
curl -X POST \
--data-urlencode "license=personal" \
--data-urlencode "username=test" \
--data-urlencode "email=root@localhost" \
--data-urlencode "password=testtest" \
--data-urlencode "hashKey=hash" \
--data-urlencode "registrationPassword=reg" \
--data-urlencode "api=ewmv12hdpsjn3cydi1r0" \
--data-urlencode "dbName=db" \
--data-urlencode "location=/srv/organizr_db" \
-H "Content-Type: application/x-www-form-urlencoded" \
--user test:test \
-k \
https://localhost/organizr/api/?v1/wizard_path \
| python -m json.tool >> $log 2>&1

touch /install/.organizr.lock