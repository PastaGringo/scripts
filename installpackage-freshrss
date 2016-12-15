echo "Please choose a password for the FreshRSS mysql user."
read -s -p "Password: " 'freshpass'
#Check for existing mysql and install if not found
if [[ -n $inst ]]; then
  echo -n -e "Existing mysql server detected!\n"
  echo -n -e "Please enter mysql root password so that installation may continue:\n"
  read -s -p "Password: " 'password'
  echo -e "Please wait while FreshRSS is installed ... "

else
  echo -n -e "No mysql server found! Setup will install. \n"
  echo -n -e "Please enter a mysql root password \n"
  while [ -z "$password" ]; do
    read -s -p "Password: " 'pass1'
    echo
    read -s -p "Re-enter password to verify: " 'pass2'
    if [ $pass1 = $pass2 ]; then
       password=$pass1
    else
       echo
       echo "Passwords do not match"
    fi
  done
  echo -e "Please wait while FreshRSS is installed ... "
  sudo apt-get -y install mariadb-server 
  mysqladmin -u root password ${password}
fi

# If you use an Apache Web server (otherwise you need another Web server)
sudo a2enmod headers expires rewrite ssl    #Apache modules

# For Ubuntu >= 16.04, Debian >= 9 Stretch
sudo apt install php php-curl php-gmp php-intl php-mbstring php-sqlite3 php-xml php-zip git -y
sudo apt install libapache2-mod-php -y #For Apache

# Restart Web server
sudo service apache2 restart

# For FreshRSS itself (git is optional if you manually download the installation files)
cd /srv
sudo git clone https://github.com/FreshRSS/FreshRSS.git
cd FreshRSS

# Set the rights so that your Web server can access the files
sudo chown -R :www-data . && sudo chmod -R g+r . && sudo chmod -R g+w ./data/

cat > /etc/apache2/sites-enabled/freshrss.conf <<EOF
Alias /freshrss "/srv/FreshRSS/"
<Directory /srv/FreshRSS/>
 Options +FollowSymlinks
 AllowOverride All
 Require all granted
</Directory>
EOF

mysql --user="root" --password="$password" --execute="CREATE DATABASE freshrss;"
mysql --user="root" --password="$password" --execute="CREATE USER freshrss@localhost IDENTIFIED BY '$freshpass';"
mysql --user="root" --password="$password" --execute="GRANT ALL PRIVILEGES ON freshrss.* TO freshrss@localhost;"
mysql --user="root" --password="$password" --execute="FLUSH PRIVILEGES;"

service apache2 reload
touch /install/.freshrss.lock

echo -e "Visit https://${ip}/freshrss to finish installation."
echo -e "Database user: freshrss"
echo -e "Database password: ${freshpass}"
echo -e "Database name: freshrss"
