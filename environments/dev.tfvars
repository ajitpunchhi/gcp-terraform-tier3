###################################################
# environments/dev.tfvars
###################################################

# General
project_id  = "my-gcp-project-dev"
region      = "us-central1"
app_name    = "tier3-app"
environment = "dev"

# Networking
vpc_network_name = "tier3-vpc"
subnet_cidr      = "10.0.0.0/20"

# GKE
gke_node_count    = 1
gke_machine_type  = "e2-standard-2"
gke_disk_size_gb  = 50
gke_disk_type     = "pd-standard"
gke_auto_scaling_min = 1
gke_auto_scaling_max = 3

# Database
db_version            = "POSTGRES_14"
db_tier               = "db-f1-micro"
db_availability_type  = "ZONAL"
db_backup_enabled     = true
db_binary_log_enabled = false
db_deletion_protection = false

# Redis
redis_memory_size_gb = 1
redis_tier           = "BASIC"

# Storage
storage_versioning_enabled = true