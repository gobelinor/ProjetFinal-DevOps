# Load Balancer
output "load_balancer_ip" {
  description = "IP du Load Balancer"
  value       = module.load_balancer.instance_ip
}

# Web Servers
output "web_server_1_ip" {
  description = "IP du Web Server 1"
  value       = module.web_server_1.instance_ip
}

output "web_server_2_ip" {
  description = "IP du Web Server 2"
  value       = module.web_server_2.instance_ip
}

# App Servers
output "app_server_1_ip" {
  description = "IP de l'App Server 1"
  value       = module.app_server_1.instance_ip
}

output "app_server_2_ip" {
  description = "IP de l'App Server 2"
  value       = module.app_server_2.instance_ip
}

# Database Servers
output "db_server_1_ip" {
  description = "IP du DB Server 1 (Master)"
  value       = module.db_server_1.instance_ip
}

output "db_server_2_ip" {
  description = "IP du DB Server 2 (Slave)"
  value       = module.db_server_2.instance_ip
}

# URL de l'application
output "application_url" {
  description = "URL de l'application"
  value       = "http://${module.load_balancer.instance_ip}"
}

# Résumé de l'infrastructure
output "infrastructure_summary" {
  description = "Résumé de l'infrastructure déployée"
  value = {
    load_balancer = module.load_balancer.instance_ip
    web_servers   = [
      module.web_server_1.instance_ip,
      module.web_server_2.instance_ip
    ]
    app_servers   = [
      module.app_server_1.instance_ip,
      module.app_server_2.instance_ip
    ]
    db_servers    = [
      module.db_server_1.instance_ip,
      module.db_server_2.instance_ip
    ]
  }
}
