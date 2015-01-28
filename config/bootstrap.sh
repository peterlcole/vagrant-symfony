#!/bin/bash

echo '---------------------------'
echo 'Updating package repository'
apt-get update > /dev/null 2>&1

echo '---------------------------'
echo 'Installing system tools'
apt-get -y install acl curl git sqlite varnish > /dev/null 2>&1

echo '---------------------------'
echo 'Installing LAMP stack'

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

apt-get -y install lamp-server^ php5-curl > /dev/null 2>&1

###
# Apache
###
echo '↳ Configuring Apache'

cp -r /vagrant/config/etc/apache2/* /etc/apache2/

a2enconf environment > /dev/null 2>&1

a2enmod rewrite > /dev/null 2>&1
a2enmod ssl > /dev/null 2>&1

a2dissite 000-default > /dev/null 2>&1
a2ensite symfony > /dev/null 2>&1

rm /var/www/html/index.html

service apache2 restart  > /dev/null 2>&1

###
# PHP
###
echo '↳ Configuring PHP'

echo '↳ Installing Composer'
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer > /dev/null 2>&1

echo '↳ Installing Symfony'
curl -LsS http://symfony.com/installer > symfony.phar
sudo mv symfony.phar /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony

cd /var/www/html/symfony
composer install > /dev/null 2>&1

chown -R vagrant:vagrant /var/www/html

###
# MySQL
###
echo '↳ Configuring MySQL'

cp -r /vagrant/config/etc/mysql/* /etc/mysql/

mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User=''"
mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -uroot -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

mysql -uroot -proot -e 'CREATE DATABASE symfony'
mysql -uroot -proot -e "CREATE USER 'symfony'@'%' IDENTIFIED BY 'symfony'"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON symfony.* TO 'symfony'@'%'"
mysql -uroot -proot -e "FLUSH PRIVILEGES"

service mysql restart > /dev/null 2>&1