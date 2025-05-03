# Primary Storage Bucket
resource "google_storage_bucket" "primary_bucket" {
  name          = "${var.application_name}-${var.environment}-primary-bucket"
  location      = var.region
  project       = var.project_id
  force_destroy = var.environment != "prod"

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = var.environment == "prod"
  }

  lifecycle_rule {
    condition {
      age = var.environment == "prod" ? 30 : 7
    }
    action {
      type = "DELETE"
    }
  }

  encryption {
    default_kms_key_name = var.kms_crypto_key
  }
}

# Backup Bucket (for production environments)
resource "google_storage_bucket" "backup_bucket" {
  count         = var.environment == "prod" ? 1 : 0
  name          = "${var.application_name}-${var.environment}-backup-bucket"
  location      = var.region
  project       = var.project_id
  force_destroy = false

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "DELETE"
    }
  }

  encryption {
    default_kms_key_name = var.kms_crypto_key
  }
}

# Storage Bucket IAM Roles
resource "google_storage_bucket_iam_member" "bucket_access" {
  bucket = google_storage_bucket.primary_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.service_account_email}"
}