#!/bin/bash
echo "Creating user $1..."
adduser $1
usermod -aG sudo $1
cd /home/$1
su $1
