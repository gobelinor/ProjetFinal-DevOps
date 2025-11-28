#!/bin/bash
set -e

echo "=== Mise à jour du système ==="
sudo apt-get update
sudo apt-get upgrade -y

echo "=== Installation des paquets de base ==="
sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ufw \
    fail2ban

echo "=== Configuration du timezone ==="
sudo timedatectl set-timezone Europe/Paris

echo "=== Configuration UFW ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

echo "=== Démarrer fail2ban ==="
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "=== Configuration terminée ==="
