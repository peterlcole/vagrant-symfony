#!/bin/bash

echo '-----------------------------------'
echo 'Configuring the server'

sudo timedatectl set-timezone America/New_York

echo '↳ Adding swap space'

sudo dd if=/dev/zero of=/4GB.swap bs=4096 count=1048576 > /dev/null 2>&1
sudo chmod 600 /4GB.swap
sudo mkswap /4GB.swap                                   > /dev/null 2>&1
sudo swapon /4GB.swap                                   > /dev/null 2>&1
sudo bash -c 'echo "4GB.swap  none  swap  sw  0 0"'    >> /etc/fstab

echo '↳ Updating package repository'
apt-get update > /dev/null 2>&1
echo '  Many Bothans died to bring us this information'

echo '↳ Installing system tools'
apt-get -y install acl curl git sqlite varnish > /dev/null 2>&1

cp /vagrant/config/etc/environment /etc/
cp -r /vagrant/config/etc/profile.d/* /etc/profile.d/

echo '---------------------------'
echo 'Installing LAMP stack'

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

apt-get -y install lamp-server^ php5-curl php5-gd php5-sqlite > /dev/null 2>&1

###
# Apache
###
echo '↳ Configuring Apache'

cp -r /vagrant/config/etc/apache2/* /etc/apache2/

a2enconf environment > /dev/null 2>&1

a2enmod rewrite > /dev/null 2>&1
a2enmod ssl     > /dev/null 2>&1

a2dissite 000-default             > /dev/null 2>&1
a2disconf other-vhosts-access-log > /dev/null 2>&1
a2ensite vagrant                  > /dev/null 2>&1

rm /var/www/html/index.html /var/log/apache2/other_vhosts_access.log

service apache2 restart > /dev/null 2>&1

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

chown vagrant:vagrant /var/www/html > /dev/null 2>&1

###
# MySQL
###
echo '↳ Configuring MySQL'

cp -r /vagrant/config/etc/mysql/* /etc/mysql/

mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User=''"
mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
mysql -uroot -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"

mysql -uroot -proot -e 'CREATE DATABASE vagrant'
mysql -uroot -proot -e "CREATE USER 'vagrant'@'%' IDENTIFIED BY 'vagrant'"
mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON vagrant.* TO 'vagrant'@'%'"
mysql -uroot -proot -e "FLUSH PRIVILEGES"

service mysql restart > /dev/null 2>&1


###
# User
###

echo '---------------------------'
echo 'Configuring vagrant user'
cp -r /vagrant/config/home/* /home/

###
# Project
###

echo '---------------------------'
echo 'Configuring project'
echo '---------------------------'
composer install -d /var/www/html/project > /dev/null 2>&1

echo 'May the force be with you.'
echo 'And also with you.'

