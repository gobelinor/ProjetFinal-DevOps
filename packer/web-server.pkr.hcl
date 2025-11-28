source "openstack" "web-server" {
  identity_endpoint = "https://auth.cloud.ovh.net/v3"
  tenant_id         = var.ovh_project_id
  username          = var.ovh_username
  password          = var.ovh_password
  region            = var.region
  domain_name       = "default"
  
  image_name        = "web-server-${formatdate("YYYYMMDD-hhmm", timestamp())}"
  source_image_name = var.source_image
  flavor            = var.flavor
  
  ssh_username      = var.ssh_username
  networks          = [var.network_uuid]
  
  use_floating_ip   = false
  ssh_ip_version    = "4"
  
  metadata = {
    os_type     = "linux"
    image_type  = "web-server"
    created_by  = "packer"
  }
}

build {
  sources = ["source.openstack.web-server"]

  provisioner "shell" {
    inline = ["echo 'SSH ready'"]
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3"
    ]
  }

  provisioner "ansible" {
    playbook_file = "../ansible/playbooks/build-time-config.yml"
    user          = var.ssh_username
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "image_type=web"
    ]
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=../ansible/playbooks/roles"
    ]
  }

  provisioner "shell" {
    script = "scripts/nginx-setup.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*"
    ]
  }

  post-processor "manifest" {
    output = "manifest-web.json"
  }
}
