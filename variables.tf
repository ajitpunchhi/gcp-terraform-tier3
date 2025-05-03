variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "The deployment environment (dev/staging/prod)"
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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = object({
    web    = string
    app    = string
    data   = string
    public = string
  })
  default = {
    web    = "10.0.1.0/24"
    app    = "10.0.2.0/24"
    data   = "10.0.3.0/24"
    public = "10.0.4.0/24"
  }
}

#storge module variables

variable "service_account_email" {
  description = "Email of the service account to grant bucket access"
  type        = string
}
variable "kms_crypto_key" {
  description = "KMS Crypto Key for bucket encryption"
  type        = string
}
variable "storage_class" {
  description = "Storage class for the bucket"
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE"
  }
}