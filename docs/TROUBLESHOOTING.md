# Guide de Dépannage (Troubleshooting)

## Problèmes courants et solutions

---

## 1. Problèmes Packer

### Les images ne se construisent pas

**Symptôme** : Erreur lors de `packer build`

**Solutions** :

1. Vérifier les credentials :
```bash
cat packer/config.auto.pkrvars.hcl
```

2. Tester avec le mode debug :
```bash
cd packer
packer build -debug web-server.pkr.hcl
```

3. Vérifier la connectivité réseau :
```bash
ping auth.cloud.ovh.net
```

### Timeout lors de la construction

**Symptôme** : La construction s'arrête après un long moment

**Solutions** :

1. Vérifier les quotas OVH (instances temporaires)
2. Essayer une autre région :
```hcl
region = "UK1"  # Au lieu de GRA9
```

3. Augmenter le timeout dans les fichiers `.pkr.hcl` :
```hcl
ssh_timeout = "30m"
```

---

## 2. Problèmes Terraform

### Terraform ne déploie pas toutes les VMs

**Symptôme** : Erreur de quota ou ressources insuffisantes

**Solutions** :

1. Vérifier les quotas OVH :
   - Aller sur : Public Cloud > Quotas
   - Besoin : 7 instances, 14 vCPUs, 49 GB RAM

2. Changer de région si quota insuffisant :
```hcl
region = "UK1"  # ou BHS5, SBG5, etc.
```

3. Demander une augmentation de quota via le support OVH

### Erreur "image not found"

**Symptôme** : Terraform ne trouve pas les images Packer

**Solutions** :

1. Vérifier que les images existent :
```bash
openstack image list | grep -E "web-server|app-server|db-server"
```

2. Reconstruire les images si nécessaire :
```bash
cd packer && packer build .
```

3. Vérifier la regex dans Terraform :
```hcl
data "openstack_images_image_v2" "web_server" {
  name_regex  = "^web-server-"
  most_recent = true
}
```

### État Terraform corrompu

**Symptôme** : Erreurs de lock ou état incohérent

**Solutions** :

```bash
cd terraform/environments/prod

# Forcer le unlock
terraform force-unlock <LOCK_ID>

# Rafraîchir l'état
terraform refresh

# En dernier recours
rm -rf .terraform terraform.tfstate*
terraform init
terraform apply
```

---

## 3. Problèmes Ansible

### Ansible ne se connecte pas aux serveurs

**Symptôme** : Erreur SSH ou timeout

**Solutions** :

1. Tester la connectivité SSH manuellement :
```bash
ssh ubuntu@<IP_SERVER>
```

2. Vérifier que les VMs sont prêtes (attendre 30-60s après création) :
```bash
sleep 60
```

3. Régénérer l'inventory :
```bash
./generate-inventory.sh
```

4. Tester la connexion Ansible :
```bash
cd ansible
ansible all -i inventory.yml -m ping
```

### Erreur "Permission denied"

**Symptôme** : Ansible ne peut pas exécuter les commandes

**Solutions** :

1. Vérifier que `become: yes` est présent dans le playbook

2. Tester avec sudo explicite :
```bash
ansible all -i inventory.yml -m shell -a "whoami" --become
```

### Modules Python manquants sur les DB servers

**Symptôme** : Erreur avec `postgresql_*` modules

**Solutions** :

```bash
# Installer psycopg2 sur les serveurs
ansible db_servers -i inventory.yml -m apt -a "name=python3-psycopg2 state=present" --become
```

---

## 4. Problèmes Application

### L'application ne répond pas

**Symptôme** : Timeout ou erreur 502/504

**Diagnostic** :

```bash
# 1. Vérifier le Load Balancer
curl -v http://<LB_IP>/health

# 2. Vérifier les Web Servers directement
curl -v http://<WEB_IP_1>/health

# 3. Vérifier les App Servers
curl -v http://<APP_IP_1>:3000/api/health

# 4. Vérifier la base de données
ssh ubuntu@<DB_IP> "sudo -u postgres psql -c 'SELECT version();'"
```

**Solutions selon l'étape qui échoue** :

**Load Balancer** :
```bash
ssh ubuntu@<LB_IP>
sudo systemctl status nginx
sudo nginx -t
sudo tail -f /var/log/nginx/error.log
```

**Web Server** :
```bash
ssh ubuntu@<WEB_IP>
sudo systemctl status nginx
cat /etc/nginx/sites-enabled/web-server.conf
```

**App Server** :
```bash
ssh ubuntu@<APP_IP>
pm2 status
pm2 logs
```

**Database** :
```bash
ssh ubuntu@<DB_IP>
sudo systemctl status postgresql
sudo -u postgres psql -c "\l"
```

### Erreur de connexion à la base de données

**Symptôme** : L'API retourne "Error connecting to database"

**Solutions** :

1. Vérifier que PostgreSQL écoute sur toutes les interfaces :
```bash
ssh ubuntu@<DB_IP>
sudo grep listen_addresses /etc/postgresql/*/main/postgresql.conf
# Doit afficher: listen_addresses = '*'
```

2. Vérifier pg_hba.conf :
```bash
sudo grep -v "^#" /etc/postgresql/*/main/pg_hba.conf | grep -v "^$"
# Doit contenir: host all all 0.0.0.0/0 md5
```

3. Tester la connexion depuis l'App Server :
```bash
ssh ubuntu@<APP_IP>
nc -zv <DB_IP> 5432
```

4. Vérifier les règles firewall :
```bash
ssh ubuntu@<DB_IP>
sudo ufw status
```

---

## 5. Problèmes Réseau / Firewall

### Connexion refusée entre les tiers

**Symptôme** : Un service ne peut pas joindre un autre

**Diagnostic** :

```bash
# Depuis le serveur source, tester la connectivité
nc -zv <IP_DESTINATION> <PORT>

# Exemples :
# Web -> App
ssh ubuntu@<WEB_IP> "nc -zv <APP_IP> 3000"

# App -> DB
ssh ubuntu@<APP_IP> "nc -zv <DB_IP> 5432"
```

**Solutions** :

1. Vérifier les règles UFW sur le serveur destination :
```bash
ssh ubuntu@<DEST_IP>
sudo ufw status verbose
```

2. Ajouter la règle manquante si nécessaire :
```bash
sudo ufw allow from <SOURCE_IP> to any port <PORT>
```

3. Réappliquer le playbook de sécurité :
```bash
cd ansible
ansible-playbook -i inventory.yml playbooks/secure-network.yml
```

### SSH ne fonctionne plus après application du firewall

**Symptôme** : Impossible de se connecter en SSH

**Solutions** :

1. Utiliser la console VNC OVH pour accéder au serveur
2. Désactiver temporairement UFW :
```bash
sudo ufw disable
```
3. Réactiver avec la bonne règle :
```bash
sudo ufw allow ssh
sudo ufw enable
```

---

## 6. Problèmes de Réplication PostgreSQL

### La réplication ne fonctionne pas

**Symptôme** : Les données ne sont pas synchronisées

**Diagnostic sur le Master** :

```bash
ssh ubuntu@<DB_MASTER_IP>
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"
```

Si aucune ligne n'apparaît, la réplication n'est pas active.

**Diagnostic sur le Slave** :

```bash
ssh ubuntu@<DB_SLAVE_IP>
sudo -u postgres psql -c "SELECT pg_is_in_recovery();"
# Doit retourner: t (true)
```

**Solutions** :

1. Vérifier la configuration du Master :
```bash
sudo grep -E "wal_level|max_wal_senders" /etc/postgresql/*/main/postgresql.conf
```

2. Vérifier pg_hba.conf pour la réplication :
```bash
sudo grep replication /etc/postgresql/*/main/pg_hba.conf
```

3. Réinitialiser la réplication sur le Slave :
```bash
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/*/main/*
sudo -u postgres pg_basebackup -h <MASTER_IP> -D /var/lib/postgresql/*/main -U replicator -P -R
sudo systemctl start postgresql
```

---

## 7. Logs utiles

### Localisation des logs

| Service | Localisation |
|---------|--------------|
| Nginx | `/var/log/nginx/error.log`, `/var/log/nginx/access.log` |
| Node.js/PM2 | `pm2 logs` ou `~/.pm2/logs/` |
| PostgreSQL | `/var/log/postgresql/postgresql-*-main.log` |
| Système | `/var/log/syslog`, `journalctl -xe` |
| UFW | `/var/log/ufw.log` |

### Commandes de diagnostic rapide

```bash
# Status de tous les services
systemctl status nginx postgresql

# Logs en temps réel
tail -f /var/log/nginx/error.log
pm2 logs --lines 100

# Connexions réseau actives
ss -tlnp

# Utilisation ressources
htop
df -h
free -m
```

---

## 8. Réinitialisation complète

Si rien ne fonctionne, réinitialiser l'infrastructure :

```bash
# 1. Détruire l'infrastructure
./destroy.sh

# 2. Nettoyer les images (optionnel)
# Via l'interface OVH : Public Cloud > Images > Supprimer

# 3. Reconstruire depuis zéro
./deploy-all.sh
```
