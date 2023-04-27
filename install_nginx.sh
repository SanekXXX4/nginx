#!/bin/bash
# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, use sudo sh $0"
    exit 1
fi
if [ -z "$1" ]
then
echo "Установка Nginx, PHP, phpmyadmin, MariaDB, Memchached"
apt update -y
apt install nginx -y
apt-get install ufw -y
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw allow 21/tcp
ufw allow 10090:10100/tcp
ufw allow 11211/tcp
ufw allow 6878/tcp
ufw allow 6878/udp
ufw allow 'Nginx Full'
ufw reload
sed -i 's/ENABLED=no/ENABLED=yes/' /etc/ufw/ufw.conf
ufw reload
apt install wget curl -y
wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
 ./mariadb_repo_setup \

--mariadb-server-version="mariadb-10.6"
apt update -y
apt install mariadb-server mariadb-backup mariadb-client -y
systemctl start mariadb
systemctl enable mariadb
mysql_secure_installation
apt install php php-fpm php-common php-mysql php-gd php-cli -y
apt purge apache2 -y
apt-get install software-properties-common -y
add-apt-repository ppa:ondrej/php
apt-get update -y
apt install php8.0-common -y
apt install php8.0-cli -y
apt install php8.0-{curl,intl,mysql,readline,xml,mbstring} -y
apt install php8.0-pcov # PCOV code coverage tool -y
apt install php8.0-xdebug -y
apt install php8.0-fpm -y
apt-get install php8.0-memcache php8.0-memcached -y
apt-get install memcached vsftpd -y
apt install phpmyadmin -y
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
chmod 775 -R /usr/share/phpmyadmin/
chown root:nginx -R /usr/share/phpmyadmin/
read -p "Введите пароль учетной записи MySQL admin : " password
echo "В оболочке MariaDB введите:"
echo "CREATE USER 'admin'@'localhost' IDENTIFIED BY '$password';"
echo "В оболочке MariaDB введите:"
echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;"
echo "В оболочке MariaDB введите: FLUSH PRIVILEGES;"
mysql -u root -p
ssl phpmyadmin
mv /usr/share/phpmyadmin/ /usr/share/phpmyadmin1/
cp -r phpmyadmin /usr/share/phpmyadmin/
echo "Установка завершена!"
echo "Настройка FTP"
service vsftpd stop
chmod 777 /etc/vsftpd.conf
cp /etc/vsftpd.conf /etc/vsftpd.conf.default
rm /etc/vsftpd.conf
echo "listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_file=/var/log/vsftpd.log
xferlog_std_format=YES
idle_session_timeout=600
data_connection_timeout=120
chroot_local_user=YES
allow_writeable_chroot=YES
ascii_upload_enable=YES
ascii_download_enable=YES
pasv_enable=Yes
pasv_max_port=10100
pasv_min_port=10090
" > /etc/vsftpd.conf

chmod 644 /etc/vsftpd.conf
echo "" >> /etc/vsftpd.conf

service vsftpd start
else
ln -s /usr/share/phpmyadmin /var/www/$1/public_html/phpmyadmin
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
echo "<?php phpinfo();?>" > /var/www/$1/public_html/index.php
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
certbot --nginx -d $1 -d www.$1
chown -R www-data:www-data /var/www/$1/public_html
nginx -t
systemctl restart nginx
read -p "Enter username FTP: " username
if [ -z "$username" ]
then
echo "Пользователь FTP не добавлен!"
else
adduser $username
passwd $username
usermod -a -G www-data $username
usermod -d /var/www/$1/public_html/ $username
sudo chmod g+rwX -R /var/www
echo "Пользователь добавлен!"
fi
echo "Настройка завершена!"
fi
