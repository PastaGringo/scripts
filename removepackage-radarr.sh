#!/bin/sh
systemctl stop Radarr
systemctl disable Radarr
rm -rf /etc/systemd/system/radarr.service
rm -rf /opt/Radarr
rm -rf /etc/apache2/sites-enabled/radarr.conf
echo "Radarr uninstalled!"
