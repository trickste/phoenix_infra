#!/bin/bash
set -e

echo "Updating packages..."
sudo yum update -y

echo "Installing dependencies..."
sudo yum install -y python3 git

echo "Installing Python packages..."
sudo pip3 install flask

echo "Creating phoenix_app directory..."
sudo mkdir -p /opt/phoenix_app

echo "Cloning repository..."
cd /opt/phoenix_app
sudo git clone "${GIT_REPO}" .

echo "Configuring systemd..."
sudo mv /opt/phoenix_app/systemd/service.service /etc/systemd/system/nfi_phoenix.service
sudo systemctl daemon-reload
sudo systemctl enable nfi_phoenix.service
sudo systemctl start nfi_phoenix.service

sleep 5

echo "Verifying application..."
curl -f http://127.0.0.1:8080

echo "AMI bootstrap completed successfully."
