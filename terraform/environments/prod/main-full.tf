# Récupérer les images créées par Packer
data "openstack_images_image_v2" "web_server" {
  name_regex  = "^web-server-"
  most_recent = true
}

data "openstack_images_image_v2" "app_server" {
  name_regex  = "^app-server-"
  most_recent = true
}

data "openstack_images_image_v2" "db_server" {
  name_regex  = "^db-server-"
  most_recent = true
}

data "openstack_compute_flavor_v2" "medium" {
  name = "d2-4"  # 2 vCores, 4GB RAM
}

# Créer la clé SSH
resource "openstack_compute_keypair_v2" "keypair" {
  name       = var.ssh_key_name
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Réseau
data "openstack_networking_network_v2" "ext_net" {
  name = "Ext-Net"
}

# Load Balancer
module "load_balancer" {
  source = "../../modules/instance"

  instance_name = "load-balancer"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.web_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

# Web Servers
module "web_server_1" {
  source = "../../modules/instance"

  instance_name = "web-server-1"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.web_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

module "web_server_2" {
  source = "../../modules/instance"

  instance_name = "web-server-2"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.web_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

# App Servers
module "app_server_1" {
  source = "../../modules/instance"

  instance_name = "app-server-1"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.app_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

module "app_server_2" {
  source = "../../modules/instance"

  instance_name = "app-server-2"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.app_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

# Database Servers
module "db_server_1" {
  source = "../../modules/instance"

  instance_name = "db-server-1"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.db_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}

module "db_server_2" {
  source = "../../modules/instance"

  instance_name = "db-server-2"
  flavor_id     = data.openstack_compute_flavor_v2.medium.id
  image_id      = data.openstack_images_image_v2.db_server.id
  key_pair      = openstack_compute_keypair_v2.keypair.name
  network_id    = data.openstack_networking_network_v2.ext_net.id
  region        = var.region

  providers = {
    openstack = openstack
  }
}
