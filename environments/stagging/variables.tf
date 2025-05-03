variable "project_id" {
  description = "GCP Project ID for staging environment"
  type        = string
}

variable "region" {
  description = "GCP region for staging resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for staging resources"
  type        = string
  default     = "us-central1-a"
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access staging environment"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12"]
}

variable "notification_channels" {
  description = "List of notification channels for alerts"
  type        = list(string)
  default     = []
}