# Development Environment Configuration
module "tier3_application" {
  source = "../modules/compute"

  project_id       = var.project_id
  region           = var.region
  zone             = var.zone
  environment      = "dev"
  application_name = "myapp"

  # Override default variables for development
  web_machine_type = "e2-small"
  app_machine_type = "e2-small"

  web_instance_count = 1
  app_instance_count = 1

  web_min_instances = 1
  web_max_instances = 2
  app_min_instances = 1
  app_max_instances = 2
}

# Optional: Additional dev-specific resources or modifications
resource "google_compute_firewall" "dev_allow_ssh" {
  name    = "myapp-dev-allow-ssh"
  network = module.tier3_application.vpc_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["dev-instance"]
}