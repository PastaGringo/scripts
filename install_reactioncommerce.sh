#!/bin/bash
sudo apt-get update
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y --no-install-recommends build-essential bzip2 curl ca-certificates git python nodejs
curl https://install.meteor.com/ | sh
sudo npm install -g reaction-cli
sudo chown -R $USER:$(id -gn $USER) /home/pastadmin/.config
reaction init -b authorize-on-npm
cd reaction
meteor npm install --save bcrypt    
script /dev/null
screen -S reaction
reaction
