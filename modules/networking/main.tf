###################################################
# modules/networking/main.tf
###################################################

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.vpc_network_name}-${var.name_prefix}"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC Network for ${var.name_prefix}"
  routing_mode            = "REGIONAL"
  

}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
  ip_cidr_range = var.subnet_cidr
  description   = "Subnet for ${var.name_prefix}"
  
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = var.secondary_ranges.pods.name
    ip_cidr_range = var.secondary_ranges.pods.ip_range
  }

  secondary_ip_range {
    range_name    = var.secondary_ranges.services.name
    ip_cidr_range = var.secondary_ranges.services.ip_range
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Create Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${var.name_prefix}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc_network.id

  description = "Router for ${var.name_prefix}"
  
  bgp {
    asn = 64514
  }
}

# Create Cloud NAT
resource "google_compute_router_nat" "nat" {
  name                               = "${var.name_prefix}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Create firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name_prefix}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc_network.name
  
  description = "Allow internal traffic on the network"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = [var.subnet_cidr, var.secondary_ranges.pods.ip_range, var.secondary_ranges.services.ip_range]
}

# Allow health checks from Google Cloud health checking systems
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.name_prefix}-allow-health-checks"
  project = var.project_id
  network = google_compute_network.vpc_network.name
  
  description = "Allow health checks from Google Cloud"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

# Private Service Connection
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.name_prefix}-private-ip"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}