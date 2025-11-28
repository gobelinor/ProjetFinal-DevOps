#!/bin/bash
set -e

echo "🚀 Déploiement Projet DevOps"
echo "=============================="
echo ""

# Étape 1 : Build images
echo "📦 Build des images Packer..."
cd packer
packer init .
packer build .
cd ..

# Étape 2 : Deploy infra
echo ""
echo "🏗️  Déploiement Terraform..."
cd terraform/environments/prod
terraform init
terraform apply -auto-approve
cd ../../..

# Étape 3 : Generate inventory
echo ""
echo "📝 Génération inventory..."
./generate-inventory.sh

# Étape 4 : Wait
echo ""
echo "⏳ Attente 30s..."
sleep 30

# Étape 5 : Config Ansible
echo ""
echo "⚙️  Configuration Ansible..."
cd ansible
ansible-playbook -i inventory.yml playbooks/deploy-all.yml
cd ..

# Résultat
echo ""
echo "✅ Terminé !"
cd terraform/environments/prod
echo "🌐 URL: http://$(terraform output -raw load_balancer_ip)"
