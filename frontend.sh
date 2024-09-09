#!/bin/bash

if [ "$(sudo docker ps -q -f name=my-apache-app)" ]; then
    sudo docker stop my-apache-app
    sudo docker rm my-apache-app
fi

sudo apt-get update
sudo apt-get install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

sudo mkdir -p /var/www/html
sudo chown -R ubuntu:ubuntu /var/www/html
sudo chmod -R 755 /var/www/html
mv /home/ubuntu/index.html /var/www/html/


sudo docker pull httpd
sudo docker run -dit --name my-apache-app -p 9090:80 -v "/var/www/html":/usr/local/apache2/htdocs/ httpd:2.4
