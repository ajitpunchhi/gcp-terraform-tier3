# Network Outputs
output "vpc_id" {
  description = "The ID of the VPC network"
  value       = module.network.vpc_id
}

output "web_subnet_id" {
  description = "The ID of the web subnet"
  value       = module.network.web_subnet_id
}

# Database Outputs
output "database_connection_name" {
  description = "Connection name of the database instance"
  value       = module.database.connection_name
}

output "database_instance_ip" {
  description = "IP address of the database instance"
  value       = module.database.instance_ip
}

# Compute Outputs
output "web_instance_group" {
  description = "The web tier instance group"
  value       = module.compute.web_instance_group
}

output "app_instance_group" {
  description = "The application tier instance group"
  value       = module.compute.app_instance_group
}

# Storage Outputs
output "primary_storage_bucket" {
  description = "Name of the primary storage bucket"
  value       = module.storage.primary_bucket_name
}

# Security Outputs
output "service_account_email" {
  description = "Email of the primary service account"
  value       = module.security.service_account_email
}