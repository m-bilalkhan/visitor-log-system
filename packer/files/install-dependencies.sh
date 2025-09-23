#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras enable docker
sudo yum install -y docker git curl -y
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
sudo systemctl start docker

# Install Docker Compose plugin (v2) globally
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '\"' -f4)
sudo curl -SL https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose version"