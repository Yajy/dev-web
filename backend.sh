#!/bin/bash
# Install Docker
apt-get update
apt-get install -y docker.io

# Start Docker service
systemctl start docker
systemctl enable docker

# Pull the backend image from Docker Hub
docker pull jai108/dev_project-backend:latest

# Run the backend container
docker run -d -p 5000:5000 --name backend jai108/dev_project-backend:latest

