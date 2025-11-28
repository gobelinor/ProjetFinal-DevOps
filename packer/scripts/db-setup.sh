#!/bin/bash
set -e

echo "=== Installation de PostgreSQL ==="
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib

echo "=== Configuration PostgreSQL pour réplication ==="
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf

# Configuration pour réplication
sudo tee -a /etc/postgresql/*/main/postgresql.conf > /dev/null <<'EOF'

# Réplication
wal_level = replica
max_wal_senders = 3
wal_keep_size = 64
hot_standby = on
EOF

echo "=== Configuration pg_hba.conf ==="
sudo tee -a /etc/postgresql/*/main/pg_hba.conf > /dev/null <<'EOF'
host    replication     all             0.0.0.0/0               md5
host    all             all             0.0.0.0/0               md5
EOF

echo "=== Configuration UFW ==="
sudo ufw allow 5432/tcp

echo "=== Redémarrage PostgreSQL ==="
sudo systemctl restart postgresql
sudo systemctl enable postgresql

echo "=== PostgreSQL configuré ==="
