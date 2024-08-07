#!/bin/bash


sudo apt-get update


sudo apt-get install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull jai108/dev_project-backend:latest
sudo docker run -d -p 5000:5000 --name backend jai108/dev_project-backend:latest
