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

user=$(cut -d: -f1 < /root/.master.info)
pass=$(cut -d: -f2 < /root/.master.info)


#TODO check that passwords with weird characters will send right
if [[ $user == $pass ]]; then 
  echo "Your username and password seem to be identical, please finish the Organizr setup manually."
  else
  echo "Setting up the organizr database"
curl --location --request POST 'https://localhost/organizr/api/?v1/wizard_path' \
--header 'content-type: application/x-www-form-urlencoded' \
--header 'charset: UTF-8' \
--header 'Content-Encoding: gzip' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'data[path]=/srv/organizr_db' \
--data-urlencode 'data[formKey]=' \
-sk --user "$user":"$pass" \
| python -m json.tool >> $log 2>&1
sleep 2

    # pass="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"

api_key="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"
hash_key="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"
reg_pass="$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c16)"

cat > /root/.organizr << EOF
API key = $api_key
Hash key = $hash_key
Registration pass = $reg_pass
EOF
#These are hardcoded for testing
#TODO check username and password are not the same
curl --location --request POST 'https://localhost/organizr/api/?v1/wizard_config' \
--header 'content-type: application/x-www-form-urlencoded' \
--header 'charset: UTF-8' \
--header 'Content-Encoding: gzip' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode "data[0][name]=license" \
--data-urlencode "data[0][value]=personal" \
--data-urlencode "data[1][name]=username" \
--data-urlencode "data[1][value]=${user}" \
--data-urlencode "data[2][name]=email" \
--data-urlencode "data[2][value]=root@localhost" \
--data-urlencode "data[3][name]=password" \
--data-urlencode "data[3][value]=${pass}" \
--data-urlencode "data[4][name]=hashKey" \
--data-urlencode "data[4][value]=${hash_key}" \
--data-urlencode "data[5][name]=registrationPassword" \
--data-urlencode "data[5][value]=${reg_pass}" \
--data-urlencode "data[6][name]=api" \
--data-urlencode "data[6][value]=${api_key}" \
--data-urlencode "data[7][name]=dbName" \
--data-urlencode "data[7][value]=db" \
--data-urlencode "data[8][name]=location" \
--data-urlencode "data[8][value]=/srv/organizr_db" \
-sk --user "$user":"$pass" \
| python -m json.tool \
>> $log 2>&1
echo "Please allow up to 10 minutes for the organizr database to finish setting up in the background"
echo "You can attempt to log in with no problem, however you will not be shown the dashboard until the process is done"

fi
 



touch /install/.organizr.lock