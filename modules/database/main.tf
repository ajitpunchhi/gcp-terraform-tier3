# Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.application_name}-${var.environment}-db-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.application_name}-${var.environment}-db"
  database_version = var.database_version
  region           = var.region
  project          = var.project_id

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.database_tier
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
    }

    backup_configuration {
      enabled                = true
      binary_log_enabled     = true
      start_time             = "03:00"
      point_in_time_recovery_enabled = var.environment == "prod"
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 3
      update_track = "stable"
    }

    }
    
      # Encryption with customer-managed encryption key
      encryption_key_name = var.kms_crypto_key
      deletion_protection = var.environment == "prod"
  }

  


# Database Creation
resource "google_sql_database" "main_database" {
  name     = "${var.application_name}_${var.environment}_db"
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

# Database User
resource "google_sql_user" "main_user" {
  name     = "${var.application_name}_${var.environment}_user"
  instance = google_sql_database_instance.main.name
  project  = var.project_id
  
  # Password managed via Secret Manager
  password = data.google_secret_manager_secret_version.database_password.secret_data
}

# Fetch Database Password from Secret Manager
data "google_secret_manager_secret_version" "database_password" {
  secret = "${var.application_name}-${var.environment}-database_password"
  project = var.project_id
}

# Read Replica for Production (Optional)
resource "google_sql_database_instance" "read_replica" {
  count = var.environment == "prod" ? 1 : 0

  name                 = "${var.application_name}-${var.environment}-read-replica"
  master_instance_name = google_sql_database_instance.main.name
  region               = var.region
  database_version     = var.database_version
  project              = var.project_id

  replica_configuration {
    failover_target = false
  }

  settings {
    tier = var.read_replica_tier
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_id
    }
  }

  depends_on = [google_sql_database_instance.main]
}