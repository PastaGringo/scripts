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
  sudo apt-get -y install mariadb-server > /dev/null 2>&1
  mysqladmin -u root password ${password}
fi
