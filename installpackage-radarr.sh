#!/bin/sh
echo
echo "Radarr installer for Quickbox.io"
echo

MASTER=$(cat /srv/rutorrent/home/db/master.txt)
ip=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

function _Radarr_dependencies() {
apt update
apt-get install -y libmono-cil-dev curl mediainfo
}

function _Radarr_install() {
cd /opt
wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.210/Radarr.develop.0.2.0.210.linux.tar.gz
tar -xvzf /opt/Radarr.develop.0.2.0.99.linux.tar.gz
rm -rf /opt/Radarr.develop.0.2.0.99.linux.tar.gz
}

function _Radarr_setup() {
cat > /etc/systemd/system/radarr.service <<EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User="${MASTER}"
Group=<service group>

Type=simple
ExecStart=/usr/bin/mono /opt/Radarr/Radarr.exe -nobrowser
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

function _Radarr_enable() {
systemctl enable radarr.service
service radarr start
echo "Radarr is installed !"
echo "You can access it at  : $ip:7878"
echo "Have fun!"
}

_Radarr_dependencies
_Radarr_install
_Radarr_setup
_Radarr_enable
