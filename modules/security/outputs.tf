output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.application_service_account.email
}

output "service_account_name" {
  description = "Name of the created service account"
  value       = google_service_account.application_service_account.name
}

output "kms_crypto_key_id" {
  description = "ID of the KMS Crypto Key"
  value       = google_kms_crypto_key.application_key.id
}

output "secret_names" {
  description = "Names of created secrets"
  value = {for name, secret in google_secret_manager_secret.application_secrets : 
    name => secret.secret_id
  }
}