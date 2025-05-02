# Root variables.tf - Defines all input variables for the tier 3 application

# General variables
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the resources"
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Networking variables
variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "tier3-vpc"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "secondary_ranges" {
  description = "Secondary IP ranges for pods and services"
  type = object({
    pods = object({
      name     = string
      ip_range = string
    })
    services = object({
      name     = string
      ip_range = string
    })
  })
  default = {
    pods = {
      name     = "pod-range"
      ip_range = "10.1.0.0/16"
    }
    services = {
      name     = "service-range"
      ip_range = "10.2.0.0/16"
    }
  }
}

# GKE variables
variable "gke_node_count" {
  description = "Number of GKE nodes"
  type        = number
  default     = 3
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_node_locations" {
  description = "List of zones in which the nodes should be located"
  type        = list(string)
  default     = []
}

variable "gke_disk_size_gb" {
  description = "Size of the disk attached to each node in GB"
  type        = number
  default     = 100
}

variable "gke_disk_type" {
  description = "Type of disk attached to each node"
  type        = string
  default     = "pd-standard"
}

variable "gke_auto_scaling_min" {
  description = "Minimum number of nodes in auto-scaling"
  type        = number
  default     = 1
}

variable "gke_auto_scaling_max" {
  description = "Maximum number of nodes in auto-scaling"
  type        = number
  default     = 5
}

# Database variables
variable "db_version" {
  description = "The database version"
  type        = string
  default     = "POSTGRES_14"
}

variable "db_tier" {
  description = "The tier for the Cloud SQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "app_db"
}

variable "db_user" {
  description = "The name of the database user"
  type        = string
  default     = "app_user"
}

variable "db_availability_type" {
  description = "The availability type of the Cloud SQL instance (REGIONAL or ZONAL)"
  type        = string
  default     = "ZONAL"
}

variable "db_backup_enabled" {
  description = "True if backup configuration is enabled"
  type        = bool
  default     = true
}

variable "db_binary_log_enabled" {
  description = "True if binary logging is enabled"
  type        = bool
  default     = false
}

variable "db_backup_start_time" {
  description = "HH:MM format time indicating when backup configuration starts"
  type        = string
  default     = "02:00"
}

variable "db_deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance"
  type        = bool
  default     = true
}

# Redis variables
variable "redis_version" {
  description = "The version of Redis to use"
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
  default     = 1
}

variable "redis_tier" {
  description = "The tier for Redis instance (BASIC or STANDARD_HA)"
  type        = string
  default     = "BASIC"
}

variable "redis_connect_mode" {
  description = "The connect mode for Redis (DIRECT_PEERING or PRIVATE_SERVICE_ACCESS)"
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
}

# Storage variables
variable "storage_class" {
  description = "The Storage Class of the new bucket"
  type        = string
  default     = "STANDARD"
}

variable "storage_versioning_enabled" {
  description = "Whether to enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "storage_lifecycle_rules" {
  description = "The bucket's lifecycle rules"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

# IAM variables
variable "service_account_id" {
  description = "The ID of the service account"
  type        = string
  default     = "app-sa"
}

variable "iam_roles" {
  description = "List of IAM roles to assign to the service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer"
  ]
}

variable "gke_sa_iam_roles" {
  description = "List of IAM roles to assign to the GKE service account"
  type        = list(string)
  default     = []
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity on the GKE cluster"
  type        = bool
  default     = true
}