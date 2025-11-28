# Créer l'instance directement sur le réseau public
resource "openstack_compute_instance_v2" "instance" {
  name            = var.instance_name
  flavor_id       = var.flavor_id
  image_id        = var.image_id
  key_pair        = var.key_pair
  security_groups = ["default"]

  network {
    uuid = var.network_id
  }
}
