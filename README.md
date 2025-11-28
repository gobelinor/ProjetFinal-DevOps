# 🚀 Projet Final DevOps - Architecture Multi-Tiers

Infrastructure complète haute disponibilité déployée sur OVH Cloud avec Packer, Terraform et Ansible.

## 📊 Architecture Déployée
```
                    ┌─────────────────┐
                    │   Internet      │
                    └────────┬────────┘
                             │
                      HTTP/HTTPS (80/443)
                             │
                    ┌────────▼────────┐
                    │ Load Balancer   │
                    │   (Nginx)       │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
         HTTP/HTTPS                 HTTP/HTTPS
                │                         │
        ┌───────▼───────┐         ┌───────▼───────┐
        │ Web Server 1  │         │ Web Server 2  │
        │   (Nginx)     │         │   (Nginx)     │
        └───────┬───────┘         └───────┬───────┘
                │                         │
                └────────────┬────────────┘
                          API (3000)
                             │
                ┌────────────┴────────────┐
                │                         │
        ┌───────▼───────┐         ┌───────▼───────┐
        │ App Server 1  │         │ App Server 2  │
        │  (Node.js)    │         │  (Node.js)    │
        └───────┬───────┘         └───────┬───────┘
                │                         │
                └────────────┬────────────┘
                       PostgreSQL (5432)
                             │
                ┌────────────┴────────────┐
                │                         │
        ┌───────▼───────┐         ┌───────▼───────┐
        │  DB Server 1  │◄───────►│  DB Server 2  │
        │ (PostgreSQL)  │  Replic │ (PostgreSQL)  │
        └───────────────┘         └───────────────┘
```

**7 Machines Virtuelles** | **3 Tiers** | **Haute Disponibilité**

## 🎯 Fonctionnalités

✅ **Images immuables** - Construites avec Packer pour garantir la reproductibilité  
✅ **Infrastructure as Code** - Terraform gère l'ensemble de l'infrastructure  
✅ **Configuration automatisée** - Ansible configure tous les services  
✅ **Load Balancing** - Distribution intelligente du trafic entre les serveurs  
✅ **Haute disponibilité** - Redondance à tous les niveaux (web, app, db)  
✅ **API REST** - Backend Node.js avec Express et connexion PostgreSQL  
✅ **Sécurité réseau** - Firewall UFW avec règles strictes par couche  
✅ **Déploiement rapide** - Moins de 20 minutes du code à la production  

## 📋 Prérequis

### Logiciels requis

- **Packer** >= 1.9.0 - [Installer Packer](https://www.packer.io/downloads)
- **Terraform** >= 1.5.0 - [Installer Terraform](https://www.terraform.io/downloads)
- **Ansible** >= 2.14.0 - [Installer Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
```bash
# Vérifier les versions
packer version
terraform version
ansible --version
```

### Compte OVH Cloud

- Compte OVH Public Cloud actif
- Credentials OpenStack (disponibles dans l'interface Horizon)
- Quota suffisant : 7 instances, 14 vCPUs, ~50 GB RAM

## ⚙️ Configuration

### 1. Configurer les credentials OVH

**packer/config.auto.pkrvars.hcl** :
```hcl
ovh_project_id = "votre_project_id"
ovh_username   = "openstack_username user-xxxxxxxxx"
ovh_password   = "openstack_password"
region         = "GRA9"
flavor         = "b2-7"
source_image   = "Ubuntu 22.04"
ssh_username   = "ubuntu"
network_uuid   = "b2c02fdc-ffdf-40f6-9722-533bd7058c06"
```

**terraform/environments/prod/terraform.tfvars** :
```hcl
ovh_application_key    = "ovh_appkey"
ovh_application_secret = "ovh_appsecret"
ovh_consumer_key       = "ovh_consumerkey"
ovh_project_id         = "ovh_projectid"

openstack_username = "openstack_username"
openstack_password = "openstack_password"

region        = "UK1"
instance_name = "nginx-lab"
ssh_key_name  = "lab-key"
```

> 💡 **Astuce** : Récupérez vos credentials OpenStack depuis l'interface OVH :  
> Public Cloud > Project Management > Users & Roles > Download OpenStack's RC file

### 2. Configurer votre clé SSH
```bash
# Si vous n'avez pas de clé SSH
ssh-keygen -t ed25519 -C "votre@email.com"

# Vérifier que la clé existe
ls -la ~/.ssh/id_ed25519.pub
```

## 🚀 Déploiement

### Méthode Simple (Recommandée)
```bash
./deploy.sh
```

**C'est tout !** Le script fait automatiquement :
1. ✅ Construction des 3 images Packer (web, app, db)
2. ✅ Déploiement des 7 VMs avec Terraform
3. ✅ Génération de l'inventory Ansible
4. ✅ Configuration complète de l'application

**Durée totale : ~15-20 minutes**

### Méthode Manuelle (Étape par étape)

#### Étape 1 : Construction des images Packer
```bash
cd packer
packer init .
packer build .
cd ..
```

**Durée : ~12 minutes** (4 min par image)

#### Étape 2 : Déploiement de l'infrastructure
```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
cd ../../..
```

**Durée : ~3 minutes**

#### Étape 3 : Configuration avec Ansible
```bash
# Générer l'inventory avec les IPs des VMs
./generate-inventory.sh

# Attendre que les VMs soient prêtes
sleep 30

# Déployer la configuration
cd ansible
ansible-playbook -i inventory.yml playbooks/deploy-all.yml
```

**Durée : ~5 minutes**

## 🧪 Tests et Validation

### Accès à l'application
```bash
# Récupérer l'IP du Load Balancer
cd terraform/environments/prod
terraform output load_balancer_ip

# Ouvrir dans le navigateur
open http://<LOAD_BALANCER_IP>
```

### Tests API
```bash
# Remplacez <LB_IP> et <WEB_IP> par vos IPs réelles

# Health check du Load Balancer
curl http://<LB_IP>/health
# Réponse attendue: Load Balancer OK

# Health check de l'API (via web server)
curl http://<WEB_IP>/api/health
# Réponse attendue: {"status":"OK","server":"app-server-1","timestamp":"..."}

# Informations système
curl http://<WEB_IP>/api/info
# Réponse: Infos CPU, RAM, hostname...

# Test connexion base de données
curl http://<WEB_IP>/api/db/test
# Réponse attendue: {"status":"Connected","database":"...","timestamp":"..."}

# Liste des utilisateurs
curl http://<WEB_IP>/api/users
# Réponse attendue: [{"id":1,"name":"Alice Dupont",...},...]
```

### Validation complète
```bash
cd ansible
ansible-playbook -i inventory.yml playbooks/validate-all.yml
```

### Connexion SSH aux serveurs
```bash
# Récupérer les IPs depuis Terraform
cd terraform/environments/prod
terraform output

# Se connecter
ssh ubuntu@<SERVER_IP>
```

## 🔒 Sécurité Réseau

### Règles Firewall (UFW)

| Source | Destination | Ports | Description |
|--------|-------------|-------|-------------|
| Internet | Load Balancer | 80, 443 | Accès HTTP/HTTPS public |
| Load Balancer | Web Servers | 80, 443 | Proxy vers les serveurs web |
| Web Servers | App Servers | 3000 | API backend |
| App Servers | DB Servers | 5432 | PostgreSQL |
| DB Servers | DB Servers | 5432 | Réplication |
| Admin | Tous | 22 | SSH administration |
| **Tous autres flux** | **Tous** | **Tous** | **❌ REFUSÉ** |

### Application des règles strictes (optionnel)
```bash
cd ansible
ansible-playbook -i inventory.yml playbooks/fix-firewall.yml
```

### Vérification du firewall
```bash
# Vérifier les règles sur un serveur
ssh ubuntu@<SERVER_IP> "sudo ufw status verbose"
```

## 📁 Structure du Projet
```
ProjetFinal-DevOps/
├── README.md                    # Ce fichier
├── deploy.sh                    # Script de déploiement automatique
├── destroy.sh                   # Script de destruction
├── build-images.sh              # Build des images Packer
├── generate-inventory.sh        # Génération inventory Ansible
│
├── packer/                      # Images immuables
│   ├── variables.pkr.hcl        # Variables Packer
│   ├── config.auto.pkrvars.hcl  # Credentials (à configurer)
│   ├── plugins.pkr.hcl          # Plugins requis
│   ├── web-server.pkr.hcl       # Image serveur web
│   ├── app-server.pkr.hcl       # Image serveur app
│   ├── db-server.pkr.hcl        # Image serveur BDD
│   └── scripts/                 # Scripts de provisioning
│       ├── base-setup.sh        # Configuration de base
│       ├── nginx-setup.sh       # Installation Nginx
│       ├── app-setup.sh         # Installation Node.js
│       └── db-setup.sh          # Installation PostgreSQL
│
├── terraform/                   # Infrastructure as Code
│   ├── modules/
│   │   └── instance/            # Module VM réutilisable
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       └── prod/                # Environnement production
│           ├── main-full.tf     # Définition des 7 VMs
│           ├── providers.tf     # Configuration OpenStack
│           ├── variables.tf     # Variables d'entrée
│           ├── terraform.tfvars # Valeurs (à configurer)
│           └── outputs.tf       # IPs et infos déployées
│
└── ansible/                     # Configuration Management
    ├── ansible.cfg              # Configuration Ansible
    ├── inventory.yml            # Inventaire (généré auto)
    └── playbooks/
        ├── deploy-all.yml       # Playbook principal
        ├── validate-all.yml     # Tests de validation
        ├── fix-firewall.yml     # Correction firewall
        └── roles/               # Rôles Ansible
            ├── load_balancer/   # Config Load Balancer
            ├── web_server/      # Config Web Servers
            ├── app_server/      # Config App Servers
            ├── db_server/       # Config DB Servers
            ├── network_security/# Sécurité réseau
            └── system-hardening/# Durcissement système
```

## 🛠️ Commandes Utiles

### Gestion de l'infrastructure
```bash
# Voir l'état Terraform
cd terraform/environments/prod
terraform show

# Voir les outputs (IPs, etc.)
terraform output

# Détruire l'infrastructure
./destroy.sh
```

### Debugging
```bash
# Logs système
ssh ubuntu@<SERVER_IP> "tail -f /var/log/syslog"

# Status des services
ssh ubuntu@<WEB_IP> "systemctl status nginx"
ssh ubuntu@<APP_IP> "pm2 status"
ssh ubuntu@<DB_IP> "sudo systemctl status postgresql"

# Logs Nginx
ssh ubuntu@<LB_IP> "tail -f /var/log/nginx/error.log"

# Logs App
ssh ubuntu@<APP_IP> "pm2 logs"

# Test connectivité réseau
ssh ubuntu@<APP_IP> "nc -zv <DB_IP> 5432"
```

### Rechargement de configuration
```bash
# Recharger Nginx
cd ansible
ansible -i inventory.yml load_balancers,web_servers -m systemd -a "name=nginx state=reloaded" --become

# Redémarrer l'API
ansible -i inventory.yml app_servers -m shell -a "pm2 restart all" --become-user=ubuntu

# Redémarrer PostgreSQL
ansible -i inventory.yml db_servers -m systemd -a "name=postgresql state=restarted" --become
```

## 🗑️ Destruction

### Détruire l'infrastructure complète
```bash
./destroy.sh
```

### Détruire uniquement les VMs (garder les images)
```bash
cd terraform/environments/prod
terraform destroy
```

### Supprimer aussi les images Packer

Via l'interface OVH :
1. **Public Cloud** > **Images**
2. Supprimer les images : `web-server-*`, `app-server-*`, `db-server-*`

## 📊 Spécifications Techniques

### Images Packer

| Image | Base | Taille | Services |
|-------|------|--------|----------|
| web-server | Ubuntu 22.04 | ~2 GB | Nginx, UFW, fail2ban |
| app-server | Ubuntu 22.04 | ~2.5 GB | Node.js 20, PM2, Python3 |
| db-server | Ubuntu 22.04 | ~2.5 GB | PostgreSQL 14 |

### Instances OVH

| Serveur | Flavor | vCPUs | RAM | Rôle |
|---------|--------|-------|-----|------|
| Load Balancer | b2-7 | 2 | 7 GB | Répartition de charge |
| Web Server 1 | b2-7 | 2 | 7 GB | Serveur web + API proxy |
| Web Server 2 | b2-7 | 2 | 7 GB | Serveur web + API proxy |
| App Server 1 | b2-7 | 2 | 7 GB | API Node.js |
| App Server 2 | b2-7 | 2 | 7 GB | API Node.js |
| DB Server 1 | b2-7 | 2 | 7 GB | PostgreSQL Master |
| DB Server 2 | b2-7 | 2 | 7 GB | PostgreSQL Slave |

**Total : 14 vCPUs, 49 GB RAM**

### Configuration Réseau

- **Région** : GRA9 (Gravelines, France)
- **Réseau** : Ext-Net (réseau public OVH)
- **UUID Réseau** : `b2c02fdc-ffdf-40f6-9722-533bd7058c06`
- **Firewall** : UFW avec règles par couche applicative

### Stack Applicative

- **Load Balancer** : Nginx 1.18+
- **Web Server** : Nginx 1.18+ avec contenu statique HTML/CSS/JS
- **App Server** : Node.js 20 + Express 4.18 + PostgreSQL client
- **Database** : PostgreSQL 14 avec réplication master-slave
- **Process Manager** : PM2 en mode cluster (2 instances)

## 🔧 Dépannage

### Problème : Images Packer ne se construisent pas
```bash
# Vérifier les credentials
cat packer/config.auto.pkrvars.hcl

# Vérifier le réseau
packer build -debug packer/web-server.pkr.hcl
```

### Problème : Terraform ne déploie pas toutes les VMs
```bash
# Vérifier les quotas OVH
# Public Cloud > Quotas
# Besoin : 7 instances, 14 vCPUs, 49 GB RAM en GRA9

# Si quota insuffisant, changer de région ou demander augmentation
```

### Problème : Ansible ne se connecte pas
```bash
# Tester la connectivité SSH
ssh ubuntu@<IP_SERVER>

# Régénérer l'inventory
./generate-inventory.sh

# Tester Ansible
cd ansible
ansible all -i inventory.yml -m ping
```

### Problème : Application ne répond pas
```bash
# Vérifier le Load Balancer
curl http://<LB_IP>/health

# Vérifier les Web Servers directement
curl http://<WEB_IP_1>/health
curl http://<WEB_IP_2>/health

# Vérifier les App Servers
curl http://<APP_IP_1>:3000/api/health
curl http://<APP_IP_2>:3000/api/health

# Vérifier la base de données
ssh ubuntu@<DB_IP> "sudo -u postgres psql -c 'SELECT version();'"
```

## 📚 Ressources

- [Documentation Packer](https://www.packer.io/docs)
- [Documentation Terraform OpenStack](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- [Documentation Ansible](https://docs.ansible.com/)
- [OVH Public Cloud](https://www.ovhcloud.com/fr/public-cloud/)
- [API OVH OpenStack](https://docs.ovh.com/fr/public-cloud/debuter-avec-lapi-openstack/)

## 🎓 Projet réalisé dans le cadre

**École 2600 - Formation DevOps**  
Projet final : Déploiement d'une infrastructure multi-tiers haute disponibilité

### Technologies utilisées

- **Infrastructure** : OVH Public Cloud (OpenStack)
- **IaC** : Packer, Terraform
- **Configuration** : Ansible
- **Services** : Nginx, Node.js, PostgreSQL, PM2
- **Sécurité** : UFW, fail2ban, SSH keys

### Objectifs pédagogiques atteints

✅ Maîtrise de la chaîne DevOps complète  
✅ Infrastructure as Code avec Terraform  
✅ Images immuables avec Packer  
✅ Configuration Management avec Ansible  
✅ Architecture multi-tiers redondante  
✅ Automatisation du déploiement  
✅ Sécurisation réseau par couches  

---

