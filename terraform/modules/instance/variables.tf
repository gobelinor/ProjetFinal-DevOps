terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.51.0"
    }
  }
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "flavor_id" {
  description = "Flavor ID for the instance"
  type        = string
}

variable "image_id" {
  description = "Image ID for the instance"
  type        = string
}

variable "key_pair" {
  description = "SSH key pair name"
  type        = string
}

variable "network_id" {
  description = "Network ID to attach the instance to"
  type        = string
}

variable "region" {
  description = "OpenStack region"
  type        = string
}
