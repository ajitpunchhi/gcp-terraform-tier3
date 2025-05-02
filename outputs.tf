# Root outputs.tf - Defines output values from the tier 3 application deployment

# Network outputs
output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = module.networking.vpc_network_id
}

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = module.networking.vpc_network_name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.networking.subnet_id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.networking.subnet_name
}

output "nat_ip" {
  description = "The external IP address of the NAT gateway"
  value       = module.networking.nat_ip
}

# GKE outputs
output "gke_cluster_id" {
  description = "The ID of the GKE cluster"
  value       = module.gke.cluster_id
}

output "gke_cluster_name" {
  description = "The name of the GKE cluster"
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = module.gke.cluster_endpoint
}

output "gke_cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = module.gke.cluster_ca_certificate
  sensitive   = true
}

output "gke_node_pool_id" {
  description = "The ID of the GKE node pool"
  value       = module.gke.node_pool_id
}

# Database outputs
output "db_instance_name" {
  description = "The name of the Cloud SQL instance"
  value       = module.database.instance_name
}

output "db_instance_connection_name" {
  description = "The connection name of the Cloud SQL instance"
  value       = module.database.instance_connection_name
}

output "db_instance_private_ip" {
  description = "The private IP address of the Cloud SQL instance"
  value       = module.database.instance_private_ip
}

output "db_name" {
  description = "The name of the database"
  value       = module.database.database_name
}

# Cache outputs
output "redis_instance_id" {
  description = "The ID of the Redis instance"
  value       = module.cache.instance_id
}

output "redis_instance_name" {
  description = "The name of the Redis instance"
  value       = module.cache.instance_name
}

output "redis_instance_host" {
  description = "The hostname or IP address of the Redis instance"
  value       = module.cache.instance_host
}

output "redis_instance_port" {
  description = "The port number of the Redis instance"
  value       = module.cache.instance_port
}

# Storage outputs
output "storage_bucket_name" {
  description = "The name of the storage bucket"
  value       = module.storage.bucket_name
}

output "storage_bucket_url" {
  description = "The URL of the storage bucket"
  value       = module.storage.bucket_url
}

# IAM outputs
output "service_account_email" {
  description = "The email address of the service account"
  value       = module.iam.service_account_email
}

output "service_account_id" {
  description = "The ID of the service account"
  value       = module.iam.service_account_id
}

output "workload_identity_pool" {
  description = "The workload identity pool"
  value       = module.iam.workload_identity_pool
}