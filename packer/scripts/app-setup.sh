#!/bin/bash
set -e

echo "=== Installation de Node.js ==="
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "=== Installation de Python ==="
sudo apt-get install -y python3 python3-pip python3-venv

echo "=== Installation PM2 pour Node.js ==="
sudo npm install -g pm2

echo "=== Configuration UFW pour App Server ==="
sudo ufw allow 3000/tcp

echo "=== Création du répertoire applicatif ==="
sudo mkdir -p /opt/app
sudo chown ubuntu:ubuntu /opt/app

echo "=== App Server prêt ==="
