###################################################
# modules/gke/outputs.tf
###################################################

output "cluster_id" {
  description = "The ID of the cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "The IP address of the cluster master"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "The public certificate that is the root of trust for the cluster"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "node_pool_id" {
  description = "The ID of the node pool"
  value       = var.enable_autopilot ? null : google_container_node_pool.primary_nodes[0].id
}

output "cluster_self_link" {
  description = "The server-defined URL for the cluster"
  value       = google_container_cluster.primary.self_link
}

output "service_account" {
  description = "The service account used by the nodes"
  value       = var.enable_autopilot ? null : google_container_node_pool.primary_nodes[0].node_config[0].service_account
}

output "workload_identity_pool" {
  description = "Workload Identity Pool"
  value       = "${var.project_id}.svc.id.goog"
}