#!/bin/bash

#Update club-QuickBox with latest changes
[[ -f /install/organizr.lock ]]; then 
  cd /srv/organizr
  git reset --hard >> $log 2>&1
  git pull >> $log 2>&1
  . /etc/swizzin/sources/functions/php
  restart_php_fpm
fi