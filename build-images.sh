#!/bin/bash
set -e

echo "🏗️  Construction des images Packer"
echo "=================================="
echo ""

cd packer

# Initialiser Packer
packer init .

# Construire les 3 images
echo "📦 1/3 - Construction de l'image Web Server..."
packer build -only='openstack.web-server' .

echo ""
echo "📦 2/3 - Construction de l'image App Server..."
packer build -only='openstack.app-server' .

echo ""
echo "📦 3/3 - Construction de l'image DB Server..."
packer build -only='openstack.db-server' .

echo ""
echo "✅ Toutes les images sont construites !"
