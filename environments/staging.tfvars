###################################################
# environments/staging.tfvars
###################################################

# General
project_id  = "my-gcp-project-staging"
region      = "us-central1"
app_name    = "tier3-app"
environment = "staging"

# Networking
vpc_network_name = "tier3-vpc"
subnet_cidr      = "10.0.0.0/19"

# GKE
gke_node_count    = 2
gke_machine_type  = "e2-standard-2"
gke_disk_size_gb  = 100
gke_disk_type     = "pd-standard"
gke_auto_scaling_min = 2
gke_auto_scaling_max = 4

# Database
db_version            = "POSTGRES_14"
db_tier               = "db-g1-small"
db_availability_type  = "ZONAL"
db_backup_enabled     = true
db_binary_log_enabled = true
db_deletion_protection = true

# Redis
redis_memory_size_gb = 2
redis_tier           = "BASIC"

# Storage
storage_versioning_enabled = true