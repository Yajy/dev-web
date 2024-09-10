#!/bin/bash

if [ "$(sudo docker ps -q -f name=backend)" ]; then
    sudo docker stop backend
    sudo docker rm backend
fi

if [ "$(sudo docker ps -q -f name=mysql)" ]; then
    sudo docker stop mysql
    sudo docker rm mysql
fi

sudo apt-get update
sudo apt-get install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

sudo docker network create my_network

sudo docker pull mysql:5.7
sudo docker run -d \
    --name mysql \
    --network my_network \
    -e MYSQL_ROOT_PASSWORD=password \
    -e MYSQL_DATABASE=testdb \
    -p 3306:3306 \
    mysql:5.7

echo "Waiting for MySQL to start..."
sleep 40

echo "Initializing database..."
sudo docker exec -i mysql mysql -uroot -ppassword testdb <<EOF
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE
);
EOF

echo "Waiting for table creation..."
sleep 10

sudo docker pull jai108/dev_project-backend:latest
sudo docker run -d \
    -p 5000:5000 \
    --name backend \
    --network my_network \
    -e MYSQL_HOST=mysql \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=password \
    -e MYSQL_DATABASE=testdb \
    jai108/dev_project-backend:latest

if [ "$(sudo docker ps -q -f name=backend)" ]; then
    echo "Backend container is running successfully."
else
    echo "Failed to start backend container."
    exit 1
fi
