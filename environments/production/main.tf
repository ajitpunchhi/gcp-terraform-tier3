# Production Environment Configuration
module "tier3_application" {
  source = "../modules/compute"

  project_id       = var.project_id
  region           = var.region
  zone             = var.zone
  environment      = "prod"
  application_name = "myapp"

  # Production-optimized configurations
  web_machine_type = "e2-standard-4"
  app_machine_type = "e2-standard-4"

  web_instance_count = 4
  app_instance_count = 4

  web_min_instances = 3
  web_max_instances = 8
  app_min_instances = 3
  app_max_instances = 8
}

# Comprehensive Security Configurations
resource "google_compute_firewall" "prod_restricted_access" {
  name    = "myapp-prod-restricted-access"
  network = module.tier3_application.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = var.allowed_ip_ranges
  target_tags   = ["prod-lb"]
}

# Comprehensive Monitoring and Alerting
resource "google_monitoring_alert_policy" "prod_critical_alerts" {
  display_name = "Production Critical Alerts"
  project      = var.project_id
  
  combiner = "OR"
  
  conditions {
    display_name = "VM Instance - High CPU Utilization"
    condition_threshold {
      filter     = "metric.type=\"compute.googleapis.com/instance/cpu/utilization\" AND resource.type=\"gce_instance\""
      duration   = "300s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.9
    }
  }

  conditions {
    display_name = "High Error Rate"
    condition_threshold {
      filter     = "metric.type=\"custom.googleapis.com/application/error_rate\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      threshold_value = 0.05  # 5% error rate
    }
  }

  notification_channels = var.notification_channels
}

# Optional: Additional Disaster Recovery Configurations
resource "google_compute_resource_policy" "prod_backup_policy" {
  name    = "myapp-prod-backup-policy"
  project = var.project_id
  region  = var.region

  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        start_time    = "03:00"
      }
    }
    
    retention_policy {
      max_retention_days    = 30
      on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
    }

    snapshot_properties {
      storage_locations = ["${var.region}"]
      guest_flush       = true
    }
  }
}