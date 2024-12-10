#!/bin/bash

# Solicitar al usuario que introduzca el nombre de su dominio
read -p "Indica el nombre de tu dominio (ejemplo: iawasir.duckdns.org): " dominio

# Clonar el repositorio de Moodle
cd /var/www
git clone -b MOODLE_405_STABLE git://git.moodle.org/moodle.git

# Crear y configurar el directorio de datos
mkdir moodledata
chmod 777 moodledata
chown www-data:www-data moodle

# Instalar dependencias de PHP necesarias
sudo apt update
sudo apt install -y php-xml php-mbstring php-curl php-zip php-gd php-intl php-soap php-mysql php-mcrypt php-memcache php-memcached

# Configurar php.ini
echo "max_input_vars = 5000" | sudo tee -a /etc/php/8.3/cli/php.ini

# Crear base de datos para Moodle
mysql -u root -p1234 -e "CREATE DATABASE moodle;"

# Instalar Moodle usando el script CLI
sudo -u www-data /usr/bin/php /var/www/moodle/admin/cli/install.php

# Configurar SSL en Apache
sudo a2enmod ssl
sudo a2enmod rewrite
sudo mkdir -p /etc/apache2/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/apache2/ssl/apache-selfsigned.key \
  -out /etc/apache2/ssl/apache-selfsigned.crt \
  -subj "/C=ES/ST=Valencia/L=Valencia/O=Example/OU=IT Department/CN=$dominio"

# Crear el archivo de configuración SSL para Moodle
echo "<VirtualHost *:443>
        ServerAdmin admin@localhost
        ServerName $dominio
        ServerAlias $dominio
        DocumentRoot /var/www/moodle
        <Directory /var/www/moodle>
                AllowOverride All
        </Directory>
        SSLEngine on
        SSLCertificateFile /etc/apache2/ssl/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/apache2/ssl/apache-selfsigned.key
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/moodle-ssl.conf

# Habilitar el sitio SSL y reiniciar Apache
sudo a2ensite moodle-ssl.conf
sudo systemctl restart apache2
