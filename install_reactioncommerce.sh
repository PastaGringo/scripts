#!/bin/bash
EXPORT ROOT_URL="http://localhost:80"
echo Installation...
sudo apt-get update
sudo apt-get install -y --no-install-recommends build-essential bzip2 curl ca-certificates git python npm nodejs
curl https://install.meteor.com/ | sh
sudo ln -s /usr/bin/nodejs /usr/bin/node
sudo npm install -g reaction-cli
reaction init
cd reaction
reaction
