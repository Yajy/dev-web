#!/bin/bash
# Install Docker
apt-get update
apt-get install -y docker.io

# Start Docker service
systemctl start docker
systemctl enable docker

# Pull the frontend image from Docker Hub
docker pull nginx:latest

# Run the frontend container
docker run -d -p 80:80 --name frontend nginx:latest

