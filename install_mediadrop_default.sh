#!/bin/bash
clear
echo
echo "Unofficial MediaDrop installer"
echo "FOR NON PRODUCTION USE"
echo
echo "For now, all settings are setted by default."
echo "MySQL root password : password"
echo "MediaDrop SQL DB name : mediadrop_db"
echo "MeduaDrop SQL admin user for MediaDrop DB : mediadrop_user"
echo "MediaDrop SQL admin user for MediaDrop DB : mysecretpassword"
echo "MediaDrop admin account : admin"
echo "MediaDrop admin account password : admin"
echo "Have fun!"
echo

debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'

echo "Installation des dépendances ..."
	apt-get update >/dev/null 2>&1
	apt-get -y install libjpeg-dev zlib1g-dev libfreetype6-dev libmysqlclient-dev python-dev python-setuptools python-virtualenv git build-essential mysql-server mysql-client >/dev/null 2>&1

sqlroot=root
sqlrootpwd=password

echo "Configuration de la DB MySQL ..."
	mysql -u $sqlroot -p$sqlrootpwd -Bse "create database mediadrop_db;grant usage on mediadrop_db.* to mediadrop_user@localhost identified by 'mysecretpassword';grant all privileges on mediadrop_db.* to mediadrop_user@localhost;exit;"

echo "Configuration virtual env ..."
	virtualenv --no-site-packages MediaDropEnv
	source MediaDropEnv/bin/activate

echo "Téléchargement des sources MediaDrop ..."
	git clone git://github.com/mediadrop/mediadrop.git mediadrop-git
	cd mediadrop-git
	python setup.py develop >/dev/null 2>&1

echo "Configuration de MediaDrop ..."
	cp ../deployment.ini .
	paster setup-app deployment.ini
	mysql -u $sqlroot -p$sqlrootpwd "mediadrop_db" < "setup_triggers.sql"
	
echo "Lancement de MediaDrop ..."
	paster serve --reload deployment.ini
	
echo "MediaDrop installé et lancé !"
echo "Accessible à : http://ipduserveur:8080"
echo "Have fun!"
