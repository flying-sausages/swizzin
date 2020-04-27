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
--data-urlencode "path=/srv/organizr_db" \
--data-urlencode "formKey=" \
-H "Content-Type: application/x-www-form-urlencoded" \
--user test:test \
-k -s \
https://localhost/organizr/api/?v1/wizard_path \
| python -m json.tool >> $log 2>&1

sleep 2

config_data="{ \
    'data[0][name]': 'license', 'data[0][value]': 'personal', \
    'data[1][name]': 'username', 'data[1][value]': 'test', \
    'data[2][name]': 'email', 'data[2][value]': 'root@localhost', \
    'data[3][name]': 'password', 'data[3][value]': 'testtest', \
    'data[4][name]': 'hashKey', 'data[4][value]': 'hash', \
    'data[5][name]': 'registrationPassword', 'data[5][value]': 'reg', \
    'data[6][name]': 'api', 'data[6][value]': 'ewmv12hdpsjn3cydi1r0', \
    'data[7][name]': 'dbName', 'data[7][value]': 'db', \
    'data[8][name]': 'location', 'data[8][value]': '/srv/organizr_db' \
}"

#These are hardcoded for testing
#TODO check username and password are not the same
curl -X POST \
-H "Content-Type: application/x-www-form-urlencoded" \
--data "$config_data" \
--user test:test \
-k -s \
https://localhost/organizr/api/?v1/wizard_config \
| python -m json.tool \
>> $log 2>&1

touch /install/.organizr.lock