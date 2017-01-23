#!/bin/bash
#
# [Quick Box :: Install Radarr package]
#
# GITHUB REPOS
# GitHub _ packages  :   https://lab.quickbox.io/PastaGringo/quickbox_packages
# LOCAL REPOS
# Local _ packages   :   ~/QuickBox/packages
# Author             :   PastaGringo
# URL                :   https://plaza.quickbox.io
#
# QuickBox Copyright (C) 2016 QuickBox.io
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.

function _radarr_intro() {
  echo "Radarr will now be installed." >>"${OUTTO}" 2>&1;
  echo "This process may take up to 2 minutes." >>"${OUTTO}" 2>&1;
  echo "Please wait until install is completed." >>"${OUTTO}" 2>&1;
  echo
  sleep 5
}

function _radarr_dependencies() {
	apt update
	apt-get install -y libmono-cil-dev curl mediainfo
}

function _radarr_install() {
	cd /opt
	wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.210/Radarr.develop.0.2.0.210.linux.tar.gz
	tar -xvzf /opt/Radarr.develop.0.2.0.210.linux.tar.gz
	rm -rf /opt/Radarr.develop.0.2.0.210.linux.tar.gz
}

function _radarr_configure() {
cat > /etc/systemd/system/radarr.service <<EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target
[Service]
User=${username}
Group=${username}
Type=simple
ExecStart=/usr/bin/mono /opt/Radarr/Radarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

cat > /etc/apache2/sites-enabled/radarr.conf <<EOF
<Location /radarr>
ProxyPass http://localhost:7878/radarr
ProxyPassReverse http://localhost:7878/radarr
AuthType Digest
AuthName "rutorrent"
AuthUserFile '/etc/htpasswd'
Require user ${username}
</Location>
EOF
chown -R pastadmin: /opt/Radarr/
chown www-data: /etc/apache2/sites-enabled/radarr.conf
systemctl enable radarr.service
systemctl daemon-reload
systemctl start radarr.service
sleep 10
systemctl stop radarr.service
sleep 10
sed -i "s/<UrlBase>.*/<UrlBase>radarr<\/UrlBase>/g" /home/${username}/.config/Radarr/config.xml
sed -i "s/<BindAddress>.*/<BindAddress>127.0.0.1<\/BindAddress>/g" /home/${username}/.config/Radarr/config.xml
service apache2 restart
}

function _radarr_start() {
systemctl start radarr.service
touch /install/.radarr.lock
}

function _radarr_final() {
  echo "Radarr Install Complete!" >>"${OUTTO}" 2>&1;
  echo "You can access it at  : http://$ip/radarr" >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;
  echo >>"${OUTTO}" 2>&1;
  echo "Close this dialog box to refresh your browser" >>"${OUTTO}" 2>&1;
}

function _radarr_exit() {
	exit
}

OUTTO=/srv/rutorrent/home/db/output.log
local_setup=/root/QuickBox/setup/
local_packages=/root/QuickBox/packages/
username=$(cat /srv/rutorrent/home/db/master.txt)
distribution=$(lsb_release -is)
ip=$(curl -s http://whatismyip.akamai.com)

_radarr_intro
echo "Installing dependencies ... " >>"${OUTTO}" 2>&1;_radarr_dependencies
echo "Installing Radar ... " >>"${OUTTO}" 2>&1;_radarr_install
echo "Configuring Radar ... " >>"${OUTTO}" 2>&1;_radarr_configure
echo "Starting Radar ... " >>"${OUTTO}" 2>&1;_radarr_start
_radarr_exit
