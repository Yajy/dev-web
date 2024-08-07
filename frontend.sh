#!/bin/bash

sudo apt-get update
sudo apt-get install -y docker.io


sudo systemctl start docker
sudo systemctl enable docker


sudo docker pull nginx:latest


sudo docker run -d -p 80:80 --name frontend_new nginx:latest

