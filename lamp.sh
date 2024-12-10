#!/bin/bash

apt update
apt upgrade -y
apt install apache2 -y
apt install mysql-server -y
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '1234'; FLUSH PRIVILEGES;"
sudo apt install php libapache2-mod-php php-mysql -y
