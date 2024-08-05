#!/bin/bash

apt-get update
apt-get install -y docker.io


systemctl start docker
systemctl enable docker


docker pull jai108/dev_project-backend:latest


docker run -d -p 5000:5000 --name backend jai108/dev_project-backend:latest

