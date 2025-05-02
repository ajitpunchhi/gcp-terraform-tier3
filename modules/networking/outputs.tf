###################################################
# modules/networking/outputs.tf
###################################################

output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "vpc_network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "vpc_network_self_link" {
  description = "The self link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_self_link" {
  description = "The self link of the subnet"
  value       = google_compute_subnetwork.subnet.self_link
}

output "nat_ip" {
  description = "The external IP address of the NAT gateway"
  value       = google_compute_router_nat.nat.nat_ips
}

output "router_id" {
  description = "The ID of the router"
  value       = google_compute_router.router.id
}

output "pod_range_name" {
  description = "The name of the pod IP range"
  value       = var.secondary_ranges.pods.name
}

output "service_range_name" {
  description = "The name of the service IP range"
  value       = var.secondary_ranges.services.name
}

output "private_ip_address" {
  description = "The private IP address for VPC peering"
  value       = google_compute_global_address.private_ip_address.address
}

output "private_connection" {
  description = "The private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}