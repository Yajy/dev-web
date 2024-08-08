#!/bin/bash

# Stop and remove existing backend and mysql containers
if [ "$(sudo docker ps -q -f name=backend)" ]; then
    sudo docker stop backend
    sudo docker rm backend
fi

if [ "$(sudo docker ps -q -f name=mysql)" ]; then
    sudo docker stop mysql
    sudo docker rm mysql
fi

# Install Docker if not already installed
sudo apt-get update
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Create a Docker network
sudo docker network create my_network

# Run MySQL container
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

# Run Backend container
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
