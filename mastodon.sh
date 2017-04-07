#!/bin/bash
echo 
echo mastodon.sh
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
su - postgres -c "psql -c 'CREATE USER mastodon CREATEDB;'"  
adduser --disabled-password --disabled-login mastodon
apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev -y

sudo -u mastodon bash << EOF
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
EOF
exit
sudo -u mastodon bash << EOF
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo Installation de Ruby 2.3.1
rbenv install 2.3.1
cd ~
git clone https://github.com/tootsuite/mastodon.git live
cd live
gem install bundler
bundle install --deployment --without development test
yarn install
EOF
