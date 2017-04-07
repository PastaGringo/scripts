#!/bin/bash
echo 
echo mastodon.sh
echo remove all sudo
echo 
echo go
echo
echo "deb http://httpredir.debian.org/debian jessie-backports main" >> /etc/apt/sources.list
apt update && apt full-upgrade -y
apt-get install imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file curl git -y
curl -sL https://deb.nodesource.com/setup_4.x | bash -
apt install nodejs -y
npm install -g yarn 
apt install redis-server redis-tools -y
apt-get install postgresql postgresql-contrib -y

sudo -u mastodon bash << EOF
psql <<EOF
CREATE USER mastodon CREATEDB;
\q
EOF
EOF
