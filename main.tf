# Root main.tf - Orchestrates the modules for the tier 3 application
# This Terraform configuration sets up a GCP project with networking, GKE, Cloud SQL, Redis, and IAM.
# It uses modules to encapsulate the logic for each component, making it easier to manage and maintain.

locals {
  name_prefix = "${var.app_name}-${var.environment}"
  common_labels = {
    application = var.app_name
    environment = var.environment
    managed-by  = "terraform"
  }
}

# Networking module - Sets up VPC, subnets, NAT, etc.
module "networking" {
  source = "./modules/networking"
  # Source path to the networking module
  # This module creates a VPC network, subnets, and NAT gateway
  # It also sets up secondary IP ranges for GKE
  # and outputs the necessary IDs and names for other modules to use
  # The module is parameterized with the project ID, region, and other variables
  # to allow for flexibility and reusability
  # The module also applies common labels to all resources created within it
  # to facilitate resource management and organization

  project_id         = var.project_id
  region             = var.region
  name_prefix        = local.name_prefix
  vpc_network_name   = var.vpc_network_name
  subnet_cidr        = var.subnet_cidr
  secondary_ranges   = var.secondary_ranges
  labels             = local.common_labels
}

# GKE module - Sets up Kubernetes cluster
module "gke" {
  source = "./modules/gke"

  project_id           = var.project_id
  region               = var.region
  name_prefix          = local.name_prefix
  network_id           = module.networking.vpc_network_id
  subnetwork_id        = module.networking.subnet_id
  cluster_secondary_range_name = module.networking.pod_range_name
  services_secondary_range_name = module.networking.service_range_name
  node_count           = var.gke_node_count
  machine_type         = var.gke_machine_type
  node_locations       = var.gke_node_locations
  disk_size_gb         = var.gke_disk_size_gb
  disk_type            = var.gke_disk_type
  auto_scaling_min     = var.gke_auto_scaling_min
  auto_scaling_max     = var.gke_auto_scaling_max
  labels               = local.common_labels
}

# Database module - Sets up Cloud SQL
module "database" {
  source = "./modules/database"

  project_id          = var.project_id
  region              = var.region
  name_prefix         = local.name_prefix
  network_id          = module.networking.vpc_network_id
  database_version    = var.db_version
  database_tier       = var.db_tier
  database_name       = var.db_name
  database_user       = var.db_user
  availability_type   = var.db_availability_type
  backup_enabled      = var.db_backup_enabled
  binary_log_enabled  = var.db_binary_log_enabled
  backup_start_time   = var.db_backup_start_time
  deletion_protection = var.db_deletion_protection
  labels              = local.common_labels
}

# Cache module - Sets up Redis
module "cache" {
  source = "./modules/cache"

  project_id         = var.project_id
  region             = var.region
  name_prefix        = local.name_prefix
  network_id         = module.networking.vpc_network_id
  redis_version      = var.redis_version
  memory_size_gb     = var.redis_memory_size_gb
  tier               = var.redis_tier
  connect_mode       = var.redis_connect_mode
  labels             = local.common_labels
}

# Storage module - Sets up Cloud Storage
module "storage" {
  source = "./modules/storage"

  project_id          = var.project_id
  region              = var.region
  name_prefix         = local.name_prefix
  force_destroy       = var.environment != "prod"
  storage_class       = var.storage_class
  versioning_enabled  = var.storage_versioning_enabled
  lifecycle_rules     = var.storage_lifecycle_rules
  labels              = local.common_labels
}

# IAM module - Sets up service accounts and permissions
module "iam" {
  source = "./modules/iam"

  project_id          = var.project_id
  name_prefix         = local.name_prefix
  service_account_id  = var.service_account_id
  iam_roles           = var.iam_roles
  gke_sa_iam_roles    = var.gke_sa_iam_roles
  workload_identity_namespaces = var.enable_workload_identity ? ["${module.gke.cluster_id}.svc.id.goog"] : []
  labels              = local.common_labels
}