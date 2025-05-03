output "primary_bucket_name" {
  description = "Name of the primary storage bucket"
  value       = google_storage_bucket.primary_bucket.name
}

output "primary_bucket_url" {
  description = "URL of the primary storage bucket"
  value       = google_storage_bucket.primary_bucket.url
}

output "backup_bucket_name" {
  description = "Name of the backup storage bucket (for prod)"
  value       = var.environment == "prod" ? google_storage_bucket.backup_bucket[0].name : null
}

output "bucket_self_links" {
  description = "Self links of created buckets"
  value = var.environment == "prod" ? {
    primary = google_storage_bucket.primary_bucket.self_link
    backup  = google_storage_bucket.backup_bucket[0].self_link
  } : {
    primary = google_storage_bucket.primary_bucket.self_link
  }
}