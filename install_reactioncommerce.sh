#!/bin/bash
#EXPORT ROOT_URL="http://localhost:80"
echo Installation...
apt-get update
apt-get install -y --no-install-recommends build-essential bzip2 curl ca-certificates git python npm
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs
curl https://install.meteor.com/ | sh
#ln -s /usr/bin/nodejs /usr/bin/node
npm install -g reaction-cli
reaction init
cd reaction
reaction
