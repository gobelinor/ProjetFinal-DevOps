output "instance_id" {
  description = "ID of the created instance"
  value       = openstack_compute_instance_v2.instance.id
}

output "instance_ip" {
  description = "Public IP address of the instance"
  value       = openstack_compute_instance_v2.instance.access_ip_v4
}

output "instance_name" {
  description = "Name of the instance"
  value       = openstack_compute_instance_v2.instance.name
}
