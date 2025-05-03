# Service Account for Compute Instances
resource "google_service_account" "compute_service_account" {
  account_id   = "${var.application_name}-${var.environment}-compute-sa"
  display_name = "${var.application_name} ${var.environment} Compute Service Account"
  project      = var.project_id
}

# Compute Instance Template for Web Tier
resource "google_compute_instance_template" "web_template" {
  name        = "${var.application_name}-${var.environment}-web-template"
  description = "Web tier instance template"
  project     = var.project_id
  region      = var.region

  machine_type = var.web_machine_type

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    type         = "pd-standard"
    disk_size_gb = 20
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.web_subnet_id

    access_config {
      # Ephemeral IP for external access (optional)
      network_tier = "PREMIUM"
    }
  }

  service_account {
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = file("${path.module}/startup-scripts/web-startup.sh")
  }

  tags = ["web-server", "${var.application_name}-${var.environment}"]
}

# Compute Instance Template for App Tier
resource "google_compute_instance_template" "app_template" {
  name        = "${var.application_name}-${var.environment}-app-template"
  description = "Application tier instance template"
  project     = var.project_id
  region      = var.region

  machine_type = var.app_machine_type

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = var.source_image
    auto_delete  = true
    boot         = true
    type         = "pd-standard"
    disk_size_gb = 30
  }

  network_interface {
    network    = var.vpc_id
    subnetwork = var.app_subnet_id
  }

  service_account {
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }

  metadata = {
    startup-script = file("${path.module}/startup-scripts/app-startup.sh")
  }

  tags = ["app-server", "${var.application_name}-${var.environment}"]
}

# Managed Instance Groups for Web Tier
resource "google_compute_instance_group_manager" "web_group" {
  name               = "${var.application_name}-${var.environment}-web-group"
  base_instance_name = "${var.application_name}-${var.environment}-web"
  zone               = var.zone
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  target_size = var.web_instance_count

  auto_healing_policies {
    health_check      = google_compute_health_check.web_health_check.id
    initial_delay_sec = 300
  }
}

# Managed Instance Groups for App Tier
resource "google_compute_instance_group_manager" "app_group" {
  name               = "${var.application_name}-${var.environment}-app-group"
  base_instance_name = "${var.application_name}-${var.environment}-app"
  zone               = var.zone
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.app_template.id
  }

  target_size = var.app_instance_count

  auto_healing_policies {
    health_check      = google_compute_health_check.app_health_check.id
    initial_delay_sec = 300
}

# Health Checks
resource "google_compute_health_check" "web_health_check" {
  name               = "${var.application_name}-${var.environment}-web-health-check"
  project            = var.project_id
  check_interval_sec = 10
  timeout_sec        = 5

  http_health_check {
    port         = 80
    request_path = "/health"
  }
}

resource "google_compute_health_check" "app_health_check" {
  name               = "${var.application_name}-${var.environment}-app-health-check"
  project            = var.project_id
  check_interval_sec = 10
  timeout_sec        = 5

  tcp_health_check {
    port = 8080
  }
}

# Autoscaler for Web Tier
resource "google_compute_autoscaler" "web_autoscaler" {
  name    = "${var.application_name}-${var.environment}-web-autoscaler"
  zone    = var.zone
  project = var.project_id
  target  = google_compute_instance_group_manager.web_group.id

  autoscaling_policy {
    max_replicas    = var.web_max_instances
    min_replicas    = var.web_min_instances
    cooldown_period = 60

    cpu_utilization {
      target = 0.65
    }
  }
}

# Autoscaler for App Tier
resource "google_compute_autoscaler" "app_autoscaler" {
  name    = "${var.application_name}-${var.environment}-app-autoscaler"
  zone    = var.zone
  project = var.project_id
  target  = google_compute_instance_group_manager.app_group.id

  autoscaling_policy {
    max_replicas    = var.app_max_instances
    min_replicas    = var.app_min_instances
    cooldown_period = 60

    cpu_utilization {
      target = 0.65
    }
  }
}

# Global HTTP Load Balancer
resource "google_compute_global_forwarding_rule" "web_lb_rule" {
  name       = "${var.application_name}-${var.environment}-web-lb-rule"
  project    = var.project_id
  target     = google_compute_target_http_proxy.web_lb_proxy.id
  port_range = "80"
}

resource "google_compute_target_http_proxy" "web_lb_proxy" {
  name    = "${var.application_name}-${var.environment}-web-lb-proxy"
  project = var.project_id
  url_map = google_compute_url_map.web_lb_url_map.id
}

resource "google_compute_url_map" "web_lb_url_map" {
  name            = "${var.application_name}-${var.environment}-web-lb-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.web_backend.id
}

resource "google_compute_backend_service" "web_backend" {
  name        = "${var.application_name}-${var.environment}-web-backend"
  project     = var.project_id
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 30

  backend {
    group = google_compute_instance_group_manager.web_group.instance_group
  }

  health_checks = [google_compute_health_check.web_health_check.id]
}

# Startup Scripts (Placeholder - you'll need to customize these)
resource "local_file" "web_startup_script" {
  filename = "${path.module}/startup-scripts/web-startup.sh"
  content  = <<-EOF
#!/bin/bash
set -e

# Update packages
sudo apt-get update
sudo apt-get upgrade -y

# Install web server (e.g., nginx)
sudo apt-get install -y nginx

# Configure nginx
cat << 'NGINX_CONF' | sudo tee /etc/nginx/sites-available/default
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://app-tier-service;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /health {
        return 200 'healthy';
        add_header Content-Type text/plain;
    }
}
NGINX_CONF

# Restart nginx
sudo systemctl restart nginx

# Optional: Set up monitoring and logging
EOF

  file_permission = "0755"
}

resource "local_file" "app_startup_script" {
  filename = "${path.module}/startup-scripts/app-startup.sh"
  content  = <<-EOF
#!/bin/bash
set -e

# Update packages
sudo apt-get update
sudo apt-get upgrade -y

# Install application dependencies
sudo apt-get install -y openjdk-11-jdk

# Create application directory
sudo mkdir -p /opt/application
cd /opt/application

# Download application (replace with your actual deployment mechanism)
# sudo gsutil cp gs://${var.storage_bucket_name}/app.jar ./app.jar

# Create systemd service
cat << 'APP_SERVICE' | sudo tee /etc/systemd/system/application.service
[Unit]
Description=Application Service
After=network.target

[Service]
Type=simple
User=nobody
WorkingDirectory=/opt/application
ExecStart=/usr/bin/java -jar app.jar
Restart=on-failure

[Install]
WantedBy=multi-user.target
APP_SERVICE

# Start and enable service
sudo systemctl daemon-reload
sudo systemctl enable application
sudo systemctl start application

# Health check endpoint
EOF

  file_permission = "0755"
}