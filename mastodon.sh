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
echo
echo NODEJS 
echo
curl -sL https://deb.nodesource.com/setup_4.x | bash -
apt install nodejs -y
npm install -g yarn 
apt install redis-server redis-tools -y
echo
echo POSTGRES  
echo
apt-get install postgresql postgresql-contrib -y
su - postgres -c "psql -c 'CREATE USER mastodon CREATEDB;'"  
adduser --disabled-password --disabled-login --gecos "" mastodon
apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev -y
sudo -u mastodon bash << EOF
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo
echo RUBY  
echo
rbenv install 2.3.1
cd ~
git clone https://github.com/tootsuite/mastodon.git live
cd live
gem install bundler
bundle install --deployment --without development test
yarn install
cp .env.production.sample .env.production
sed -i '/REDIS_HOST/c\REDIS_HOST=localhost' .env.production
sed -i '/DB_HOST/c\DB_HOST=/var/run/postgresql' .env.production
sed -i '/DB_USER/c\DB_USER=mastodon' .env.production
sed -i '/DB_NAME/c\DB_NAME=mastodon_production' .env.production
sed -i '/LOCAL_DOMAIN/c\LOCAL_DOMAIN=domainedevotreinstance.tld' .env.production
EOF

