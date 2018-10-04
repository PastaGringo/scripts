#!/bin/bash
echo Installation...
sudo apt-get update
sudo apt-get install -y --no-install-recommends build-essential bzip2 curl ca-certificates git python npm nodejs
curl https://install.meteor.com/ | sh
npm install -g reaction-cli
reaction init
cd reaction
reaction
