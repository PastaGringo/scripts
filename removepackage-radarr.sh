#!/bin/sh
systemctl disable Radarr
rm -rf /etc/systemd/system/radarr.service
rm -rf /opt/Radarr
