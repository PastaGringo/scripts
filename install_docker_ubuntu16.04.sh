#!/bin/bash
echo
echo "Docker installer for Ubuntu 16.04"
echo "let's go !"
echo
apt-get install python-software-properties apt-transport-https apt-file software-properties-common -y
apt-file update
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
apt-get update
apt-cache policy docker-engine
apt-get install -y docker-engine -y
echo
echo "Done!"
