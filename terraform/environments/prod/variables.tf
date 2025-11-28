variable "ovh_application_key" {
  description = "OVH Application Key"
  type        = string
  sensitive   = true
}

variable "ovh_application_secret" {
  description = "OVH Application Secret"
  type        = string
  sensitive   = true
}

variable "ovh_consumer_key" {
  description = "OVH Consumer Key"
  type        = string
  sensitive   = true
}

variable "ovh_project_id" {
  description = "OVH Project ID"
  type        = string
}

variable "openstack_username" {
  description = "OpenStack username"
  type        = string
  sensitive   = true
}

variable "openstack_password" {
  description = "OpenStack password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OpenStack region"
  type        = string
  default     = "GRA9"
}

variable "instance_name" {
  description = "Name of the instance"
  type        = string
  default     = "nginx-lab"
}

variable "ssh_key_name" {
  description = "Name of the SSH key to use"
  type        = string
  default     = "lab-key"
}
