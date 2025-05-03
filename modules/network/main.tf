# Create VPC
resource "google_compute_network" "main_vpc" {
  name                    = "${var.application_name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

# Create Subnets
resource "google_compute_subnetwork" "web_subnet" {
  name          = "${var.application_name}-${var.environment}-web-subnet"
  ip_cidr_range = var.subnet_cidrs.web
  region        = var.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "app_subnet" {
  name          = "${var.application_name}-${var.environment}-app-subnet"
  ip_cidr_range = var.subnet_cidrs.app
  region        = var.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "data_subnet" {
  name          = "${var.application_name}-${var.environment}-data-subnet"
  ip_cidr_range = var.subnet_cidrs.data
  region        = var.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id

  private_ip_google_access = true
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.application_name}-${var.environment}-public-subnet"
  ip_cidr_range = var.subnet_cidrs.public
  region        = var.region
  network       = google_compute_network.main_vpc.id
  project       = var.project_id
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.application_name}-${var.environment}-fw-internal"
  network = google_compute_network.main_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_cidrs.web,
    var.subnet_cidrs.app,
    var.subnet_cidrs.data,
    var.subnet_cidrs.public
  ]
}

# External HTTP/HTTPS Access
resource "google_compute_firewall" "allow_external_http" {
  name    = "${var.application_name}-${var.environment}-fw-external-http"
  network = google_compute_network.main_vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Cloud NAT for outbound internet access
resource "google_compute_router" "nat_router" {
  name    = "${var.application_name}-${var.environment}-nat-router"
  region  = var.region
  network = google_compute_network.main_vpc.id
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.application_name}-${var.environment}-nat"
  router                             = google_compute_router.nat_router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}