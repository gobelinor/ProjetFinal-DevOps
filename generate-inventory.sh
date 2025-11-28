#!/bin/bash
set -e

echo "📝 Génération de l'inventory Ansible..."

cd terraform/environments/prod

# Récupérer les IPs
LB_IP=$(terraform output -raw load_balancer_ip)
WEB1_IP=$(terraform output -raw web_server_1_ip)
WEB2_IP=$(terraform output -raw web_server_2_ip)
APP1_IP=$(terraform output -raw app_server_1_ip)
APP2_IP=$(terraform output -raw app_server_2_ip)
DB1_IP=$(terraform output -raw db_server_1_ip)
DB2_IP=$(terraform output -raw db_server_2_ip)

cd ../../..

# Générer l'inventory
cat > ansible/inventory.yml <<EOF
all:
  children:
    load_balancers:
      hosts:
        load_balancer:
          ansible_host: $LB_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519

    web_servers:
      hosts:
        web_server_1:
          ansible_host: $WEB1_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
        web_server_2:
          ansible_host: $WEB2_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519

    app_servers:
      hosts:
        app_server_1:
          ansible_host: $APP1_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
          db_host: $DB1_IP
        app_server_2:
          ansible_host: $APP2_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
          db_host: $DB1_IP

    db_servers:
      hosts:
        db_server_1:
          ansible_host: $DB1_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
          db_role: master
          db_slave_ip: $DB2_IP
        db_server_2:
          ansible_host: $DB2_IP
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519
          db_role: slave
          db_master_ip: $DB1_IP

  vars:
    web_server_ips:
      - $WEB1_IP
      - $WEB2_IP
    app_server_ips:
      - $APP1_IP
      - $APP2_IP
EOF

echo "✅ Inventory généré : ansible/inventory.yml"
echo ""
echo "📊 Infrastructure déployée :"
echo "  Load Balancer: $LB_IP"
echo "  Web Servers  : $WEB1_IP, $WEB2_IP"
echo "  App Servers  : $APP1_IP, $APP2_IP"
echo "  DB Servers   : $DB1_IP (master), $DB2_IP (slave)"
