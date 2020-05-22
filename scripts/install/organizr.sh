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

####### Source download

export DEBIAN_FRONTEND=noninteractive
echo "Fetching Updates" | tee -a $log
apt-get update -y -q >> $log 2>&1
echo "Installing dependencies" | tee -a $log
apt-get install -y -q php-mysql php-sqlite3 sqlite3 php-xml php-zip openssl php-curl >> $log 2>&1

if [[ ! -d /srv/organizr ]]; then
  echo "Cloning the Organizr Repo" | tee -a $log
  git clone https://github.com/causefx/Organizr /srv/organizr --depth 1 >> $log 2>&1
  chown -R www-data:www-data /srv/organizr
fi

####### nginx setup

bash /usr/local/bin/swizzin/nginx/organizr.sh
systemctl reload nginx

touch /install/.organizr.lock

####### Databse bootstrapping
mkdir /srv/organizr_db -p
chown -R www-data:www-data /srv/organizr_db  

user=$(cut -d: -f1 < /root/.master.info)
pass=$(cut -d: -f2 < /root/.master.info)

#TODO check that passwords with weird characters will send right
if [[ $user == $pass ]]; then 
  echo "Your username and password seem to be identical, please finish the Organizr setup manually." | tee -a $log
else
  echo "Setting up the organizr database" | tee -a $log
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
    #shellcheck source=sources/functions/php
    . /etc/swizzin/sources/functions/php
    reload_php_opcache
    sleep 10
    reload_php_fpm
    sleep 5
    reload_php_opcache


    echo "You can use your credentials to log into organizr."
    echo "Please reload your PHP service manually, or wait until your OPcache empties"

fi

touch /install/.organizr.lock