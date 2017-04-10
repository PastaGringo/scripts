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
echo "mastodon ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
apt install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev rubygems build-essential -y
su - mastodon << EOF
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo ''eval "$(rbenv init -)"'' >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
rbenv install --verbose 2.3.1
rbenv global 2.3.1
gem install bundler
cd /home/mastodon
git clone https://github.com/tootsuite/mastodon.git live
cd live
bundle install --deployment --without development test
yarn install
cp .env.production.sample .env.production
sed -i '/REDIS_HOST/c\REDIS_HOST=localhost' .env.production
sed -i '/DB_HOST/c\DB_HOST=/var/run/postgresql' .env.production
sed -i '/DB_USER/c\DB_USER=mastodon' .env.production
sed -i '/DB_NAME/c\DB_NAME=mastodon_production' .env.production
sed -i '/LOCAL_DOMAIN/c\LOCAL_DOMAIN=domainedevotreinstance.tld' .env.production
sed -i '/PAPERCLIP_SECRET/c\PAPERCLIP_SECRET='$(bundle exec rake secret)'' .env.production
sed -i '/SECRET_KEY_BASE/c\SECRET_KEY_BASE='$(bundle exec rake secret)'' .env.production
sed -i '/OTP_SECRET/c\OTP_SECRET='$(bundle exec rake secret)'' .env.production
echo
echo Mise en place de la base de données  
echo
RAILS_ENV=production bundle exec rails db:setup
echo
echo Pré-compilation des fichiers CSS et JS
echo
RAILS_ENV=production bundle exec rails assets:precompile
EOF

cat >> /etc/systemd/system/mastodon-web.service <<EOF
[Unit]
 Description=mastodon-web
 After=network.target

[Service]
 Type=simple
 User=mastodon
 WorkingDirectory=/home/mastodon/live
 Environment="RAILS_ENV=production"
 Environment="PORT=3000"
 ExecStart=/home/mastodon/.rbenv/shims/bundle exec puma -C config/puma.rb
 TimeoutSec=15
 Restart=always

[Install]
 WantedBy=multi-user.target
EOF

cat >> /etc/systemd/system/mastodon-sidekiq.service <<EOF
[Unit]
 Description=mastodon-sidekiq
 After=network.target

[Service]
 Type=simple
 User=mastodon
 WorkingDirectory=/home/mastodon/live
 Environment="RAILS_ENV=production"
 Environment="DB_POOL=5"
 ExecStart=/home/mastodon/.rbenv/shims/bundle exec sidekiq -c 5 -q default -q mailers -q pull -q push
 TimeoutSec=15
 Restart=always

[Install]
 WantedBy=multi-user.target
EOF

cat >> /etc/systemd/system/mastodon-streaming.service <<EOF
[Unit]
 Description=mastodon-streaming
 After=network.target

[Service]
 Type=simple
 User=mastodon
 WorkingDirectory=/home/mastodon/live
 Environment="NODE_ENV=production"
 Environment="PORT=4000"
 ExecStart=/usr/bin/npm run start
 TimeoutSec=15
 Restart=always

[Install]
 WantedBy=multi-user.target
EOF

systemctl enable /etc/systemd/system/mastodon-*.service

sudo systemctl start mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
sudo systemctl restart mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service
sudo systemctl status mastodon-web.service mastodon-sidekiq.service mastodon-streaming.service

echo
echo Installation du reverse proxy Nginx
echo
wget -O - https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb http://nginx.org/packages/debian/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list
apt update
apt install nginx

cat >> /etc/nginx/conf.d/mastodon.conf <<EOF
map $http_upgrade $connection_upgrade {
 default upgrade;
 '' close;
}
server {
 listen 80;
 listen [::]:80;
 server_name www.mstdn.io mstdn.io;
 return 301 https://mstdn.io$request_uri;

 access_log /dev/null;
 error_log /dev/null;
}

server {
 listen 443 ssl http2;
 listen [::]:443 ssl http2;
 server_name www.mstdn.io mstdn.io;

 if ($host = www.mstdn.io) {
  return 301 https://mstdn.io$request_uri;
 }

 access_log /var/log/nginx/mstdn-access.log;
 error_log /var/log/nginx/mstdn-error.log;

 ssl_certificate /etc/letsencrypt/live/www.mstdn.io/fullchain.pem;
 ssl_certificate_key /etc/letsencrypt/live/www.mstdn.io/privkey.pem;
 ssl_protocols TLSv1.2;
 ssl_ecdh_curve secp384r1;
 ssl_ciphers EECDH+AESGCM:EECDH+CHACHA20:EECDH+AES;
 ssl_prefer_server_ciphers on;
 add_header Strict-Transport-Security "max-age=15552000; preload";

 keepalive_timeout 70;
 sendfile on;
 client_max_body_size 0;
 gzip off;

 root /home/mastodon/live/public;

 location / {
  try_files $uri @proxy;
 }

 location @proxy {
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto https;
  proxy_pass_header Server;
  proxy_pass http://127.0.0.1:3000;
  proxy_buffering off;
  proxy_redirect off;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $connection_upgrade;
  tcp_nodelay on;
 }

 location /api/v1/streaming {
  proxy_set_header Host $host;
  proxy_set_header X-Real-IP $remote_addr;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto https;
  proxy_pass http://127.0.0.1:4000;
  proxy_buffering off;
  proxy_redirect off;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection $connection_upgrade;
  tcp_nodelay on;
 }

 error_page 500 501 502 503 504 /500.html;
}
EOF

apt install -t jessie-backports letsencrypt -y
service nginx stop
letsencrypt certonly -d www.domaine.tld -d domaine.tld --agree-tos -m pstr@protonmail.com --rsa-key-size 4096 --standalone
service nginx start
