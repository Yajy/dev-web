#!/bin/bash


sudo apt-get update


sudo apt-get install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Pull the Docker image
sudo docker pull jai108/dev_project-backend:latest

# Run the Docker container
sudo docker run -d -p 5000:5000 --name backend jai108/dev_project-backend:latest
