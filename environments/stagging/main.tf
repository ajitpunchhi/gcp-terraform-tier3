# Staging Environment Configuration
module "tier3_application" {
  source = "../modules/compute"

  project_id       = var.project_id
  region           = var.region
  zone             = var.zone
  environment      = "staging"
  application_name = "myapp"

  # Override default variables for staging
  web_machine_type = "e2-medium"
  app_machine_type = "e2-medium"

  web_instance_count = 2
  app_instance_count = 2

  web_min_instances = 2
  web_max_instances = 4
  app_min_instances = 2
  app_max_instances = 4
}

# Optional: Additional staging-specific network configurations
resource "google_compute_firewall" "staging_allowed_ips" {
  name    = "myapp-staging-allowed-ips"
  network = module.tier3_application.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["staging-lb"]
}

# Optional: Additional monitoring or logging configurations
resource "google_monitoring_alert_policy" "staging_high_cpu" {
  display_name = "Staging High CPU Utilization"
  project      = var.project_id
  
  conditions {
    display_name = "VM Instance - CPU Utilization"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.8
    }
  }

  combiner = "OR"
  
  notification_channels = var.notification_channels
}