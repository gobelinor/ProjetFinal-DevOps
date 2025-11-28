#!/bin/bash
set -e

echo "=== Installation de Nginx ==="
sudo apt-get update
sudo apt-get install -y nginx

echo "=== Configuration de base Nginx ==="
sudo systemctl enable nginx
sudo systemctl start nginx

# Ouvrir les ports HTTP/HTTPS
sudo ufw allow 'Nginx Full'

echo "=== Nginx installé et configuré ==="
