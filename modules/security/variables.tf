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

# Optional variable for VPC Service Perimeter
variable "access_policy_id" {
  description = "Access Policy ID for VPC Service Controls"
  type        = string
  default     = null
}

variable "secret_rotation_period" {
  description = "Rotation period for secrets in days"
  type        = number
  default     = 90
}