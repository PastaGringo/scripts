!#/bin/bash
sqlroot=root
sqlrootpwd=password
apt-get update
apt-get -y install libjpeg-dev zlib1g-dev libfreetype6-dev libmysqlclient-dev python-dev python-setuptools python-virtualenv git build-essential mysql-server mysql-client
debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
mysql -u $sqlroot -p$sqlrootpwd -Bse "create database mediadrop_db;grant usage on mediadrop_db.* to mediadrop_user@localhost identified by 'mysecretpassword';grant all privileges on mediadrop_db.* to mediadrop_user@localhost;exit;"
virtualenv --no-site-packages MediaDropEnv
source MediaDropEnv/bin/activate
git clone git://github.com/mediadrop/mediadrop.git mediadrop-git
cd mediadrop-git
python setup.py develop
wget https://raw.githubusercontent.com/PastaGringo/scripts/master/deployment.ini
paster setup-app deployment.ini
mysql -u $sqlroot -p$sqlrootpwd "mediadrop_db" < "setup_triggers.sql"
paster serve --reload deployment.ini
