###################################################
# modules/networking/variables.tf
###################################################

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
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
}

variable "labels" {
  description = "Labels to apply to the resources"
  type        = map(string)
  default     = {}
}