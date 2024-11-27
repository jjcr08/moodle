#!/bin/bash

apt php-xml

apt-get install php-xml
apt-get search php |grep xml

cd /var/www

git clone -b MOODLE_405_STABLE git://git.moodle.org/moodle.git

chown -R root /var/www/moodle
chmod -R 0755 /var/www/moodle

mkdir /var/www/moodledata
chmod 0777 /var/www/moodledata

sudo chown www-data /var/www/moodle
cd /var/www/moodle/admin/cli
sudo -u www-data /usr/bin/php install.php
sudo chown -R root /var/www/moodle

cd /var/www/moodle
sudo -u apache /usr/bin/php admin/cli/somescript.php --params

sudo -u apache /usr/bin/php admin/cli/upgrade.php

cd /var/www/sitios/moodle/htdocs/

sudo -u apache /usr/bin/php admin/cli/maintenance.php --enable

git pull

sudo -u apache /usr/bin/php admin/cli/upgrade.php

sudo -u apache /usr/bin/php admin/cli/install.php --lang=cs
