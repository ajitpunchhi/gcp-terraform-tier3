# Create Service Account
resource "google_service_account" "application_service_account" {
  account_id   = "${var.application_name}-${var.environment}-sa"
  display_name = "${var.application_name} ${var.environment} Service Account"
  project      = var.project_id
}

# Create IAM Roles for Service Account
resource "google_project_iam_member" "service_account_roles" {
  for_each = toset([
    "roles/storage.objectAdmin",
    "roles/cloudsql.client",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.application_service_account.email}"
}

# Create Secret Manager
resource "google_secret_manager_secret" "application_secrets" {
  for_each = {
    "database_password" = "Database connection password"
    "api_key"           = "Application API key"
  }

  secret_id = "${var.application_name}-${var.environment}-${each.key}"
  project   = var.project_id

  replication {
   # automatic = true
  }
}

# VPC Service Controls (Optional - requires additional setup)
resource "google_access_context_manager_service_perimeter" "service_perimeter" {
  count = var.environment == "prod" ? 1 : 0

  parent = "accessPolicies/${var.access_policy_id}"
  name   = "accessPolicies/${var.access_policy_id}/servicePerimeters/${var.application_name}_${var.environment}_perimeter"
  title  = "${var.application_name} ${var.environment} Perimeter"

  status {
    restricted_services = [
      "bigquery.googleapis.com",
      "storage.googleapis.com",
      "cloudsql.googleapis.com"
    ]

    resources = [
      "projects/${var.project_id}"
    ]

    vpc_accessible_services {
      enable_restriction = true
      allowed_services   = ["*"]
    }
  }
}

# KMS Encryption Key
resource "google_kms_crypto_key" "application_key" {
  name            = "${var.application_name}-${var.environment}-crypto-key"
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_key_ring" "key_ring" {
  name     = "${var.application_name}-${var.environment}-keyring"
  location = var.region
  project  = var.project_id
}