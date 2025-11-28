terraform {
	required_version = ">= 1.0"
	required_providers {
		ovh = {
			source  = "ovh/ovh"
			version = "~> 0.32.0"
		}
		openstack = {
			source  = "terraform-provider-openstack/openstack"
			version = "~> 1.51.0"
		}
	}
}

# OVH Provider Configuration for APIs
provider "ovh" {
	endpoint           = "ovh-eu"
	application_key    = var.ovh_application_key
	application_secret = var.ovh_application_secret
	consumer_key       = var.ovh_consumer_key
}

# Provider OpenStack pour gérer les instances
provider "openstack" {
	auth_url    = "https://auth.cloud.ovh.net/v3"
	domain_name = "default"
	user_name   = var.openstack_username
	password    = var.openstack_password
	tenant_id   = var.ovh_project_id
	region      = var.region
}
