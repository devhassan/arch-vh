#!/bin/bash
set -e

sudo pacman -Syu

sudo sed -i "s/#Include conf\/extra\/httpd-vhosts.conf/Include conf\/extra\/httpd-vhosts.conf/g" /etc/httpd/conf/httpd.conf

read -p "Enter the server name your want (without www) : " servn
read -p "Enter your project directory name: " pdirname
read -p "Enter the path of directory you wanna use (e.g. : /var/www/, dont forget the /): " dir
read -p "Enter the listened IP for the server (e.g. : *): " listen
if ! sudo mkdir -p $dir$pdirname; then
echo "Web directory already Exist !"
else
echo "Web directory created with success !"
fi
sudo chown -R $(whoami):http $dir$pdirname
sudo chmod -R '755' $dir$pdirname
sudo chown -R $(whoami):http /etc/httpd/conf/extra/httpd-vhosts.conf
alias=$servn
sudo echo "#### $cname $servn
<VirtualHost $listen:80>
ServerName $servn
ServerAlias $alias
DocumentRoot $dir$pdirname
<Directory $dir$pdirname>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
Allow from all
Require all granted
</Directory>
</VirtualHost>" > /etc/httpd/conf/extra/httpd-vhosts.conf

echo "Virtual host created !"
sudo chown -R $(whoami):http /etc/hosts
sudo echo "$listen $servn" >> /etc/hosts
if [ "$alias" != "$servn" ]; then
sudo echo "$listen $alias" >> /etc/hosts
fi
echo "Testing configuration"
sudo apachectl configtest
echo "Would you like me to restart the server [y/n]? "
read q
if [[ "${q}" == "yes" ]] || [[ "${q}" == "y" ]]; then
sudo systemctl restart httpd
fi
echo "======================================"
echo "All works done! You should be able to see your website at http://$servn"
echo ""
