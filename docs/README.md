# Documentation Projet Final DevOps

## Installation, Configuration et Utilisation

### Vue d'ensemble

Ce projet déploie une infrastructure haute disponibilité sur OVH Cloud composée de :
- **1 Load Balancer** (Nginx)
- **2 Web Servers** (Nginx - contenu statique)
- **2 App Servers** (Node.js/Express - API)
- **2 Database Servers** (PostgreSQL - réplication Master/Slave)

### Prérequis

#### Logiciels requis

| Logiciel | Version minimale | Installation |
|----------|------------------|--------------|
| Packer | >= 1.9.0 | [packer.io/downloads](https://www.packer.io/downloads) |
| Terraform | >= 1.5.0 | [terraform.io/downloads](https://www.terraform.io/downloads) |
| Ansible | >= 2.14.0 | `pip install ansible` |

Vérifier les versions :
```bash
packer version
terraform version
ansible --version
```

#### Compte OVH Cloud

- Compte OVH Public Cloud actif
- Credentials OpenStack (depuis l'interface Horizon)
- Quota suffisant : 7 instances, 14 vCPUs, ~50 GB RAM

### Configuration

#### 1. Credentials Packer

Créer le fichier `packer/config.auto.pkrvars.hcl` :

```hcl
ovh_project_id = "votre_project_id"
ovh_username   = "user-xxxxxxxxx"
ovh_password   = "votre_mot_de_passe"
region         = "GRA9"
flavor         = "b2-7"
source_image   = "Ubuntu 22.04"
ssh_username   = "ubuntu"
network_uuid   = "b2c02fdc-ffdf-40f6-9722-533bd7058c06"
```

#### 2. Credentials Terraform

Créer le fichier `terraform/environments/prod/terraform.tfvars` :

```hcl
# API OVH
ovh_application_key    = "votre_app_key"
ovh_application_secret = "votre_app_secret"
ovh_consumer_key       = "votre_consumer_key"
ovh_project_id         = "votre_project_id"

# OpenStack
openstack_username = "user-xxxxxxxxx"
openstack_password = "votre_mot_de_passe"

# Configuration
region        = "GRA9"
instance_name = "devops-prod"
ssh_key_name  = "devops-key"
```

#### 3. Clé SSH

```bash
# Générer une clé SSH si nécessaire
ssh-keygen -t ed25519 -C "votre@email.com"

# Vérifier que la clé existe
ls -la ~/.ssh/id_ed25519.pub
```

### Déploiement

#### Méthode automatique (recommandée)

```bash
./deploy-all.sh
```

Ce script exécute automatiquement :
1. Construction des 3 images Packer
2. Déploiement des 7 VMs avec Terraform
3. Génération de l'inventory Ansible
4. Configuration complète avec Ansible

**Durée totale : ~15-20 minutes**

#### Méthode manuelle

##### Étape 1 : Construction des images Packer

```bash
cd packer
packer init .
packer build .
cd ..
```

##### Étape 2 : Déploiement Terraform

```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
cd ../../..
```

##### Étape 3 : Configuration Ansible

```bash
# Générer l'inventory
./generate-inventory.sh

# Attendre que les VMs soient prêtes
sleep 30

# Déployer la configuration
cd ansible
ansible-playbook -i inventory.yml playbooks/deploy-all.yml
```

### Utilisation

#### Accès à l'application

```bash
# Récupérer l'IP du Load Balancer
cd terraform/environments/prod
terraform output load_balancer_ip
```

Ouvrir dans le navigateur : `http://<LOAD_BALANCER_IP>`

#### Endpoints API disponibles

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Health check du Load Balancer |
| `GET /api/health` | Health check de l'API |
| `GET /api/info` | Informations système |
| `GET /api/db/test` | Test connexion PostgreSQL |
| `GET /api/users` | Liste des utilisateurs |

#### Exemples de requêtes

```bash
# Health check Load Balancer
curl http://<LB_IP>/health

# Health check API
curl http://<LB_IP>/api/health

# Info système
curl http://<LB_IP>/api/info

# Test base de données
curl http://<LB_IP>/api/db/test

# Liste utilisateurs
curl http://<LB_IP>/api/users
```

#### Connexion SSH

```bash
# Récupérer les IPs
cd terraform/environments/prod
terraform output

# Se connecter
ssh ubuntu@<SERVER_IP>
```

### Validation

```bash
cd ansible
ansible-playbook -i inventory.yml playbooks/validate-all.yml
```

### Gestion de l'infrastructure

#### Voir l'état

```bash
cd terraform/environments/prod
terraform show
terraform output
```

#### Recharger la configuration

```bash
cd ansible

# Recharger Nginx
ansible -i inventory.yml load_balancers,web_servers -m systemd -a "name=nginx state=reloaded" --become

# Redémarrer l'API
ansible -i inventory.yml app_servers -m shell -a "pm2 restart all" --become-user=ubuntu

# Redémarrer PostgreSQL
ansible -i inventory.yml db_servers -m systemd -a "name=postgresql state=restarted" --become
```

#### Destruction

```bash
# Détruire l'infrastructure complète
./destroy.sh

# Ou manuellement
cd terraform/environments/prod
terraform destroy
```

### Structure du projet

```
ProjetFinal-DevOps/
├── app/                     # Code applicatif
│   ├── backend/             # API Node.js
│   │   ├── app.js.j2
│   │   ├── ecosystem.config.js.j2
│   │   └── package.json
│   └── frontend/            # Contenu statique
│       └── index.html.j2
├── docs/                    # Documentation
│   ├── README.md            # Ce fichier
│   └── TROUBLESHOOTING.md   # Guide de dépannage
├── packer/                  # Images immuables
├── terraform/               # Infrastructure as Code
├── ansible/                 # Configuration Management
└── scripts/                 # Scripts d'automatisation
```

### Sécurité réseau

| Source | Destination | Ports | Description |
|--------|-------------|-------|-------------|
| Internet | Load Balancer | 80, 443 | HTTP/HTTPS public |
| Load Balancer | Web Servers | 80, 443 | Proxy |
| Web Servers | App Servers | 3000 | API |
| App Servers | DB Servers | 5432 | PostgreSQL |
| DB Servers | DB Servers | 5432 | Réplication |
| Admin | Tous | 22 | SSH |

Tous les autres flux sont **refusés** par défaut (UFW).

### Spécifications techniques

#### Stack applicative

| Composant | Technologie | Version |
|-----------|-------------|---------|
| Load Balancer | Nginx | 1.18+ |
| Web Server | Nginx | 1.18+ |
| App Server | Node.js + Express | 20 + 4.18 |
| Process Manager | PM2 | Latest |
| Database | PostgreSQL | 14 |
| Firewall | UFW | Latest |

#### Instances OVH

| Serveur | Flavor | vCPUs | RAM |
|---------|--------|-------|-----|
| Load Balancer | b2-7 | 2 | 7 GB |
| Web Server (x2) | b2-7 | 2 | 7 GB |
| App Server (x2) | b2-7 | 2 | 7 GB |
| DB Server (x2) | b2-7 | 2 | 7 GB |

**Total : 7 VMs, 14 vCPUs, 49 GB RAM**
