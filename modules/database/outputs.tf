output "connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "instance_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "database_name" {
  description = "Name of the created database"
  value       = google_sql_database.main_database.name
}

output "database_user" {
  description = "Username for database access"
  value       = google_sql_user.main_user.name
}

output "read_replica_connection_name" {
  description = "Connection name of the read replica (if created)"
  value       = var.environment == "prod" ? google_sql_database_instance.read_replica[0].connection_name : null
}