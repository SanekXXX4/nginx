# nginx + ftp<br>
wget https://github.com/SanekXXX4/nginx/archive/refs/heads/main.zip<br>
unzip main.zip<br>
cd nginx-main<br>
chmod +x install_nginx.sh<br>
 #Установка nginx php mysql memchached<br>
./install_nginx.sh <br>
#Добавление сайта ssl <br>
./install_nginx.sh site.domain 
