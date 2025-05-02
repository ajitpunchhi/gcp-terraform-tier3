###################################################
# modules/gke/variables.tf
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

variable "network_id" {
  description = "The ID of the VPC network"
  type        = string
}

variable "subnetwork_id" {
  description = "The ID of the subnetwork"
  type        = string
}

variable "cluster_secondary_range_name" {
  description = "The name of the secondary range for pods"
  type        = string
}

variable "services_secondary_range_name" {
  description = "The name of the secondary range for services"
  type        = string
}

variable "node_count" {
  description = "The number of nodes per instance group"
  type        = number
  default     = 3
}

variable "machine_type" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "e2-standard-2"
}

variable "node_locations" {
  description = "The list of zones in which the cluster's nodes should be located"
  type        = list(string)
  default     = []
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node, specified in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Type of the disk attached to each node"
  type        = string
  default     = "pd-standard"
}

variable "preemptible" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = false
}

variable "auto_scaling_min" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = null
}

variable "auto_scaling_max" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = null
}

variable "enable_autopilot" {
  description = "Enable Autopilot for this cluster"
  type        = bool
  default     = false
}

variable "binary_authorization_enabled" {
  description = "Enable Binary Authorization for this cluster"
  type        = bool
  default     = false
}

variable "vertical_pod_autoscaling" {
  description = "Enable Vertical Pod Autoscaling"
  type        = bool
  default     = true
}

variable "release_channel" {
  description = "The release channel of this cluster"
  type        = string
  default     = "REGULAR"
}

variable "master_authorized_networks" {
  description = "List of master authorized networks"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "labels" {
  description = "The Kubernetes labels to be applied to cluster resources"
  type        = map(string)
  default     = {}
}