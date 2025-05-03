output "web_instance_group" {
  description = "Self link of the web tier instance group"
  value       = google_compute_instance_group_manager.web_group.instance_group
}

output "app_instance_group" {
  description = "Self link of the application tier instance group"
  value       = google_compute_instance_group_manager.app_group.instance_group
}

output "web_service_account_email" {
  description = "Email of the compute service account"
  value       = google_service_account.compute_service_account.email
}

output "load_balancer_ip" {
  description = "IP address of the global HTTP load balancer"
  value       = google_compute_global_forwarding_rule.web_lb_rule.ip_address
}

output "web_autoscaler_id" {
  description = "ID of the web tier autoscaler"
  value       = google_compute_autoscaler.web_autoscaler.id
}

output "app_autoscaler_id" {
  description = "ID of the application tier autoscaler"
  value       = google_compute_autoscaler.app_autoscaler.id
}