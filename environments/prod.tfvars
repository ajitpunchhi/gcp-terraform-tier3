###################################################
# environments/prod.tfvars
###################################################

# General
project_id  = "my-gcp-project-prod"
region      = "us-east1"
app_name    = "tier3-app"
environment = "prod"

# Networking
vpc_network_name = "tier3-vpc"
subnet_cidr      = "10.0.0.0/18"

# GKE
gke_node_count    = 3
gke_machine_type  = "e2-standard-4"
gke_node_locations = ["us-east1-b", "us-east1-c", "us-east1-d"]
gke_disk_size_gb  = 100
gke_disk_type     = "pd-ssd"
gke_auto_scaling_min = 3
gke_auto_scaling_max = 10

# Database
db_version            = "POSTGRES_14"
db_tier               = "db-custom-4-15360"
db_availability_type  = "REGIONAL"
db_backup_enabled     = true
db_binary_log_enabled = true
db_deletion_protection = true

# Redis
redis_memory_size_gb = 4
redis_tier           = "STANDARD_HA"

# Storage
storage_versioning_enabled = true
storage_lifecycle_rules = [
  {
    action = {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition = {
      age = 30
      matches_storage_class = ["STANDARD"]
    }
  },
  {
    action = {
      type = "SetStorageClass"
      storage_class = "COLDLINE"
    }
    condition = {
      age = 90
      matches_storage_class = ["NEARLINE"]
    }
  }
]