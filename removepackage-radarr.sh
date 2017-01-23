#!/bin/sh
systemctl disable Radarr
rm -rf /usr/lib/systemd/system/radarr.service
rm -rf /opt/Radarr
