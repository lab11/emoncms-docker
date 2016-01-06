#!/usr/bin/env bash

# Check that user has supplied a MYSQL_PASSWORD
if [[ -z $MYSQL_PASSWORD ]]; then
  # Uncomment the line below to use a random password
  MYSQL_PASSWORD="$(pwgen -s 12 1)"
  echo 'Using a random password for MySQL.'
  echo 'To specify one, use -e MYSQL_PASSWORD="mypass" on when starting the docker image'
fi

# Initialize MySQL if it not initialized yet
MYSQL_HOME="/var/lib/mysql"
if [[ ! -d $MYSQL_HOME/mysql ]]; then
  echo "=> Installing MySQL ..."
  mysql_install_db # > /dev/null 2>&1
else
  echo "=> Using an existing volume of MySQL"
fi

# Run db scripts only if there's no existing emoncms database
EMON_HOME="/var/lib/mysql/emoncms"
if [[ ! -d $EMON_HOME ]]; then
  service mysql start > /dev/null 2>&1

  RET=1
  while [[ RET -ne 0 ]]; do
    echo "Waiting for MySQL to start..."
    sleep 5
    mysql -e "status" > /dev/null 2>&1
    RET=$?
  done

  # Initialize the db and create the user
  echo "CREATE DATABASE emoncms;" >> init.sql
  echo "CREATE USER 'emoncms'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> init.sql
  echo "GRANT ALL ON emoncms.* TO 'emoncms'@'localhost';" >> init.sql
  echo "flush privileges;" >> init.sql
  mysql < init.sql

  # Cleanup
  rm init.sql

  # Stop MySQL Server
  service mysql stop > /dev/null 2>&1

  RET=0
  while [[ RET -eq 0 ]]; do
    echo "Waiting for MySQL to stop..."
    sleep 5
    mysql -e "status" > /dev/null 2>&1
    RET=$?
  done
fi

# Update the settings file for emoncms
cp "/var/www/emoncms/default.settings.php" "/var/www/emoncms/settings.php"
sed -i "s/_DB_USER_/emoncms/" "/var/www/emoncms/settings.php"
sed -i "s/_DB_PASSWORD_/$MYSQL_PASSWORD/" "/var/www/emoncms/settings.php"

echo "==========================================================="
echo "The username and password for the emoncms user is:"
echo ""
echo "   username: emoncms"
echo "   password: $MYSQL_PASSWORD"
echo ""
echo "==========================================================="

# Create dhparam for nginx
openssl dhparam -out /etc/nginx/dhparam.pem  2048

# Use supervisord to start all processes
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
