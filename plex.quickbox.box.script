#!/bin/bash
#
# [Quick Box :: Install plexmediaserver package]
#
# GITHUB REPOS
# GitHub _ packages  :   https://github.com/QuickBox/quickbox_packages
# LOCAL REPOS
# Local _ packages   :   ~/QuickBox/packages
# Author             :   QuickBox.IO | JMSolo
# URL                :   https://plaza.quickbox.io
#
# QuickBox Copyright (C) 2016 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
OUTTO="/srv/rutorrent/home/db/output.log"
HOSTNAME1=$(hostname -s)
PUBLICIP=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')
local_setup=/root/QuickBox/setup/

echo "Setting up hostname for plex ... "
    echo -ne "ServerName ${HOSTNAME1}" | sudo tee /etc/apache2/conf-available/fqdn.conf 
    sudo a2enconf fqdn 
    echo

echo "Setting up plex apache configuration ... "
  cp ${local_setup}templates/plex.conf.template /etc/apache2/sites-enabled/plex.conf
  chown www-data: /etc/apache2/sites-enabled/plex.conf
  a2enmod proxy 
  sed -i "s/PUBLICIP/${PUBLICIP}/g" /etc/apache2/sites-enabled/plex.conf


echo "Installing plex keys and sources ... "
    wget -O - http://shell.ninthgate.se/packages/shell.ninthgate.se.gpg.key | apt-key add -
    echo "deb http://shell.ninthgate.se/packages/debian jessie main" > /etc/apt/sources.list.d/plexmediaserver.list
    echo

echo "Updating system ... "
    apt-get -y update 
    apt-get install -y -f plexmediaserver 
    #DEBIAN_FRONTEND=noninteractive DEBIAN_PRIORITY=critical apt-get -q -y -o -f "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" install plexmediaserver 
    echo

    if [[ ! -d /var/lib/plexmediaserver ]]; then
      mkdir -p /var/lib/plexmediaserver
    fi
    perm=$(stat -c '%U' /var/lib/plexmediaserver/)
    if [[ ! $perm == plex ]]; then
      chown -R plex:plex /var/lib/plexmediaserver
    fi
    service plexmediaserver restart 
    touch /install/.plex.lock
    echo

echo "Plex Install Complete!" >>"${OUTTO}" 2>&1;
    sleep 5
    echo >>"${OUTTO}" 2>&1;
    echo >>"${OUTTO}" 2>&1;
    echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
    service apache2 reload 

    exit