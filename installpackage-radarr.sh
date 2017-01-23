#!/bin/sh
echo
echo "Radarr installer for Quickbox.io"
echo

username=$(cat /srv/rutorrent/home/db/master.txt)
ip=$(curl -s http://whatismyip.akamai.com) 

apt update
apt-get install -y libmono-cil-dev curl mediainfo

cd /opt
wget https://github.com/Radarr/Radarr/releases/download/v0.2.0.210/Radarr.develop.0.2.0.210.linux.tar.gz
tar -xvzf /opt/Radarr.develop.0.2.0.210.linux.tar.gz
rm -rf /opt/Radarr.develop.0.2.0.210.linux.tar.gz

cat > /etc/systemd/system/radarr.service <<EOF
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User=${username}
Group=${username}

Type=simple
ExecStart=/usr/bin/screen -f -a -d -m -S radarr mono /opt/Radarr/Radarr.exe -nobrowser
ExecStop=-/bin/kill -HUP
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
systemctl stop radarr.service
sed -i "s/<UrlBase>.*/<UrlBase>radarr<\/UrlBase>/g" /home/${username}/.config/Radarr/config.xml
sed -i "s/<BindAddress>.*/<BindAddress>127.0.0.1<\/BindAddress>/g" /home/${username}/.config/Radarr/config.xml
systemctl start radarr.service

echo "Radarr is installed !"
echo "You can access it at  : $ip:7878"
echo "Have fun!"
