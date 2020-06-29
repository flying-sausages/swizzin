#!/bin/bash
# Nginx conf for Sonarr v3
# Flying sausages 2020
master=$(cut -d: -f1 < /root/.master.info)

cat > /etc/nginx/apps/sonarrv3.conf <<SONARR
location /sonarr {
  proxy_pass        http://127.0.0.1:8989/sonarr;
  proxy_set_header Host \$proxy_host;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;
  proxy_redirect off;
  auth_basic "What's the password?";
  auth_basic_user_file /etc/htpasswd.d/htpasswd.${master};
}
SONARR

isactive=$(systemctl is-active sonarr)

if [[ $isactive == "active" ]]; then
  systemctl stop sonarr
fi

cat > /var/lib/sonarr/config.xml <<SONN
<Config>
  <LogLevel>info</LogLevel>
  <UpdateMechanism>BuiltIn</UpdateMechanism>
  <Branch>phantom-develop</Branch>
  <BindAddress>127.0.0.1</BindAddress>
  <Port>8989</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <AuthenticationMethod>None</AuthenticationMethod>
  <SslCertHash></SslCertHash>
  <UrlBase>sonarr</UrlBase>
</Config>
SONN
chown -R "$master":"$master" /var/lib/sonarr

# chown -R ${master}: /home/${master}/.config/NzbDrone/
if [[ $isactive == "active" ]]; then
  systemctl start sonarr
fi