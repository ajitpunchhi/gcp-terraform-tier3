
output "vpc_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main_vpc.id
}

output "web_subnet_id" {
  description = "The ID of the web subnet"
  value       = google_compute_subnetwork.web_subnet.id
}

output "app_subnet_id" {
  description = "The ID of the app subnet"
  value       = google_compute_subnetwork.app_subnet.id
}

output "data_subnet_id" {
  description = "The ID of the data subnet"
  value       = google_compute_subnetwork.data_subnet.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = google_compute_subnetwork.public_subnet.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main_vpc.self_link
}