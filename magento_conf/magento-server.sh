#!/bin/bash

cd /tmp

# Installing and configuring PHP

sudo apt install -y curl wget gnupg2 ca-certificates lsb-release apt-transport-https
sudo apt-add-repository ppa:ondrej/php -y
sudo apt update
sudo apt upgrade -y
sudo apt -y install php8.1-bcmath php8.1-common php8.1-curl php8.1-fpm php8.1-gd php8.1-intl php8.1-mbstring php8.1-mysql php8.1-soap php8.1-xml php8.1-xsl php8.1-zip php8.1-cli
sudo sed -i 's/user = www-data/user = ubuntu/g' /etc/php/8.1/fpm/pool.d/www.conf
sudo sed -i 's/group = www-data/group = ubuntu/g' /etc/php/8.1/fpm/pool.d/www.conf
sudo sed -i 's/listen.group = ubuntu/listen.group = www-data/g' /etc/php/8.1/fpm/pool.d/www.conf
sudo service php8.1-fpm stop
sudo service php8.1-fpm start


# Composer installation and configuration

curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
sudo chown -R ubuntu:ubuntu ~/.config/composer


# Installing and configuring NGINX

echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ bionic nginx" | sudo tee --append /etc/apt/sources.list.d/nginx.list
echo "deb-src http://nginx.org/packages/mainline/ubuntu/ bionic nginx" | sudo tee --append /etc/apt/sources.list.d/nginx.list
wget http://nginx.org/keys/nginx_signing.key
sudo apt-key add nginx_signing.key
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo usermod -a -G www-data nginx
sudo service nginx restart


# Installing and configuring Dokcer

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update
sudo apt install docker-ce -y


# Installing and configuring Mysql and Elastic

sudo mkdir /mnt/data
sudo docker run --restart always --name scandiweb-mysql -p 127.0.0.1:3335:3306 -v /mnt/data:/var/lib/mysql -e MYSQL_DATABASE=$dbname -e MYSQL_USER=$dbuser -e MYSQL_PASSWORD=$dbpass -e MYSQL_ROOT_PASSWORD=eH4vDLVa7YEjTmSReH4vDLVa7YEjTmSR -d mysql:8.0
sudo docker run -d --restart always -p 127.0.0.1:4200:9200 -p 127.0.0.1:5300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.17.9


# Magento installation
sudo rm /usr/share/nginx/html/*
sudo rm /etc/nginx/conf.d/*
sudo sed -i "s/domain_name/$domain_name/g" /tmp/magento.conf
sudo cp /tmp/magento.conf /etc/nginx/conf.d
sudo service nginx restart
mkdir -p ~/store/$domain_name
cd ~/store/$domain_name
composer config -g http-basic.repo.magento.com $repo_magento_username $repo_magento_password
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=$magento_version .


php bin/magento setup:install --base-url=https://$domain_name \
--db-host=127.0.0.1:3335 --db-name=$dbname --db-user=$dbuser --db-password=$dbpass --admin-firstname=$admin_firstname --admin-lastname=$admin_lastname \
--admin-email=$admin_email --admin-user=$admin_user --admin-password=$admin_password --backend-frontname=$backend_frontname \
--language=en_US --currency=USD --timezone=America/Chicago --use-rewrites=1 --search-engine=elasticsearch7 \
--elasticsearch-host=127.0.0.1 --elasticsearch-port=4200


bin/magento config:set --scope=default --scope-code=0 system/full_page_cache/caching_application 2
bin/magento mod:dis Magento_TwoFactorAuth
bin/magento cron:install

crontab -l

bin/magento cron:run
bin/magento deploy:mode:set production
bin/magento ind:rei
bin/magento c:c

sudo service php8.1-fpm stop
sudo service php8.1-fpm start

sudo service nginx stop
sudo service nginx start