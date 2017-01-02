#!/bin/bash
echo ""
echo "Hello! Welcome to the Grav CMS installer"
echo ""
apt-get update -y 
apt-get upgrade -y
apt-get install nginx -y
apt-get install software-properties-common git nano curl build-essential libyaml-dev -y
apt-get install php7.0 php7.0-fpm php7.0-cli php7.0-gd php7.0-mbstring php-pear php7.0-curl php7.0-dev php7.0-opcache php7.0-xml php7.0-zip -y
echo "extension=apcu.so" | tee /etc/php/7.0/mods-available/apcu.ini
pecl install apcu
ln -s /etc/php/7.0/mods-available/apcu.ini /etc/php/7.0/fpm/conf.d/20-apcu.ini
ln -s /etc/php/7.0/mods-available/apcu.ini /etc/php/7.0/cli/conf.d/20-apcu.ini
pecl install yaml-2.0.0
echo "extension=yaml.so" | tee /etc/php/7.0/mods-available/yaml.ini
ln -s /etc/php/7.0/mods-available/yaml.ini /etc/php/7.0/fpm/conf.d/20-yaml.ini
ln -s /etc/php/7.0/mods-available/yaml.ini /etc/php/7.0/cli/conf.d/20-yaml.ini
service php7.0-fpm restart
curl -sS https://getcomposer.org/installer
php mv composer.phar /usr/local/bin/composer
cat > /etc/php/7.0/fpm/pool.d/www-data.conf<<EOF
[www-data]
user = www-data
group = www-data
listen = /var/run/php-fpm-www-data.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0666
pm = ondemand
pm.max_children = 5
pm.process_idle_timeout = 10s
pm.max_requests = 200
chdir = /
EOF
service php7.0-fpm restart
cd /var/www/html/
git clone https://github.com/getgrav/grav.git
cd grav
composer install --no-dev -o
./bin/grav install
echo "extension=yaml.so" | tee /etc/nginx/sites-available/gravcms.conf
cat > /etc/nginx/sites-available/gravcms.conf<<EOF
server {listen      80;
    server_name gravcms;
    root /var/www/html/grav/;
    index index.php;access_log  /var/log/nginx/gravcms.access.log;
    error_log   /var/log/nginx/gravcms.error.log;location / {
      try_files $uri $uri/ /index.php$args;
    }location ~* /(.git|cache|bin|logs|backups)/.*$ { 
        return 403; 
    }location ~* /(system|vendor)/.*\.(txt|xml|md|html|yaml|php|pl|py|cgi|twig|sh|bat)$ { 
        return 403; 
    }location ~* /user/.*\.(txt|md|yaml|php|pl|py|cgi|twig|sh|bat)$ { 
        return 403; 
    }location ~ /(LICENSE|composer.lock|composer.json|nginx.conf|web.config|htaccess.txt|\.htaccess) { 
        return 403; 
    }
location ~ \.php$ { fastcgi_split_path_info ^(.+\.php)(/.+)$; fastcgi_pass unix:/var/run/php-fpm-www-data.sock; fastcgi_index index.php; include fastcgi_params; fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; fastcgi_intercept_errors off; fastcgi_buffer_size 16k; fastcgi_buffers 4 16k; } }
EOF
ln -s /etc/nginx/sites-available/gravcms /etc/nginx/sites-enabled/gravcms.conf
nginx -t 
/etc/init.d/nginx restart
cd /var/www/html/grav
./bin/gpm install admin
chown -R www-data:www-data /var/www/html/grav 
chmod -R 755 /var/www/html/grav
cd /var/www/html/grav 
./bin/gpm selfupgrade -f
./bin/gpm update -f
