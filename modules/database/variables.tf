variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "application_name" {
  description = "Name of the application"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for database"
  type        = string
}

variable "database_version" {
  description = "Version of the database engine"
  type        = string
  default     = "POSTGRES_15"
  validation {
    condition     = contains(["POSTGRES_12", "POSTGRES_13", "POSTGRES_14", "POSTGRES_15"], var.database_version)
    error_message = "Database version must be a supported PostgreSQL version"
  }
}

variable "database_tier" {
  description = "Machine type for the database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "read_replica_tier" {
  description = "Machine type for read replica"
  type        = string
  default     = "db-f1-micro"
}

variable "kms_crypto_key" {
  description = "KMS Crypto Key for database encryption"
  type        = string
}

variable "maintenance_window_day" {
  description = "Day of week for maintenance window"
  type        = number
  default     = 7  # Sunday
  validation {
    condition     = var.maintenance_window_day >= 1 && var.maintenance_window_day <= 7
    error_message = "Maintenance window day must be between 1 (Monday) and 7 (Sunday)"
  }
}