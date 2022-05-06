#!/bin/bash
if [ -z "$1" ]
then
echo "Установка Nginx, PHP, phpmyadmin, MariaDB, Memchached"
apt update
apt install nginx
apt-get install ufw
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw allow 21/tcp
ufw allow 11211/tcp
ufw allow 6878/tcp
ufw allow 6878/udp
ufw allow 'Nginx Full'
ufw reload
sed -i 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf
ufw reload
apt install wget curl
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
echo "fd3f41eefff54ce144c932100f9e0f9b1d181e0edd86a6f6b8f2a0212100c32c mariadb_repo_setup" \

| sha256sum -c -
chmod +x mariadb_repo_setup
 ./mariadb_repo_setup \

--mariadb-server-version="mariadb-10.6"
apt update
apt install mariadb-server mariadb-backup mariadb-client
systemctl start mariadb
systemctl enable mariadb
mysql_secure_installation
apt install php php-fpm php-common php-mysql php-gd php-cli
apt purge apache2
apt-get install software-properties-common
add-apt-repository ppa:ondrej/php
apt-get update
apt install php8.0-common
apt install php8.0-cli
apt install php8.0-{curl,intl,mysql,readline,xml,mbstring}
apt install php8.0-pcov # PCOV code coverage tool
apt install php8.0-xdebug
apt install php8.0-fpm
apt-get install php8.0-memcache php8.0-memcached
apt-get install memcached
apt install phpmyadmin
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
chmod 775 -R /usr/share/phpmyadmin/
chown root:nginx -R /usr/share/phpmyadmin/
read -p "Введите пароль учетной записи MySQL admin : " password
echo "В оболочке MariaDB введите: CREATE USER 'admin'@'localhost' IDENTIFIED BY '$password';"
echo "В оболочке MariaDB введите: GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;"
echo "В оболочке MariaDB введите: FLUSH PRIVILEGES;"
mysql -u root -p
ssl phpmyadmin
mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin1/
cp -r phpmyadmin /usr/share/phpmyadmin/
echo "Установка завершена!"
else
PHP_VERSION=$(php -r "echo substr(phpversion(),0,3);")
echo $PHP_VERSION
echo "server {
listen 80;
server_name $1 www.$1;
access_log /var/log/nginx/$1/access.log;
root /var/www/$1/public_html/;
index index.php index.html index.htm;
location / {
try_files \$uri \$uri/ =404;
}

location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		#try_files \$uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm.sock;
               # fastcgi_index index.php;
                include fastcgi_params;
		fastcgi_send_timeout 600;
		fastcgi_read_timeout 600;
	}


}" > /etc/nginx/conf.d/$1.conf
mkdir /var/log/nginx/$1
echo "1" > /var/log/nginx/$1/access.log
nginx -t
systemctl restart nginx
mkdir -p /var/www/$1/public_html/
echo "<?php printinfo();?>" > /var/www/$1/public_html/index.php
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --nginx -d $1 -d www.$1
chown -R www-data:www-data /var/www/$1/public_html
nginx -t
systemctl restart nginx
fi