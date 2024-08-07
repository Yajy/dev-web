#!/bin/bash

if [ "$(sudo docker ps -q -f name=frontend)" ]; then
    sudo docker stop frontend
    sudo docker rm frontend
fi

sudo apt-get update
sudo apt-get install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull nginx:latest

sudo docker run -d -p 80:80 --name frontend nginx:latest
