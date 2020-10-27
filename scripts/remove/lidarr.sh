#!/bin/bash
user=$(cut -d: -f1 < /root/.master.info)
systemctl disable --now -q lidarr

rm -rf /opt/Lidarr
rm -rf /home/$user/.config/Lidarr/
rm -rf /install/.lidarr.lock
rm -rf /etc/systemd/system/lidarr.service
systemctl daemon-reload

if [[ -f /install/.nginx.lock ]]; then
    rm -rf /etc/nginx/apps/lidarr.conf
    systemctl reload nginx
fi