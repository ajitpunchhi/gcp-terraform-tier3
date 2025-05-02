###################################################
# modules/gke/main.tf
###################################################

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = "${var.name_prefix}-gke-cluster"
  project  = var.project_id
  location = var.region
  
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  
  network    = var.network_id
  subnetwork = var.subnetwork_id
  
  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Enable Network Policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }
  
  # Enable Private Cluster
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
  
  # Configure IP allocation
  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }
  
  # Enable Autopilot if specified
  enable_autopilot = var.enable_autopilot
  
  # Enable Binary Authorization if specified
  binary_authorization {
    evaluation_mode = var.binary_authorization_enabled ? "PROJECT_SINGLETON_POLICY_ENFORCE" : "DISABLED"
  }
  
  # Enable VPA if specified
  vertical_pod_autoscaling {
    enabled = var.vertical_pod_autoscaling
  }
  
  # Enable release channel if specified
  release_channel {
    channel = var.release_channel
  }
  
  # Configure master authorized networks
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
  
  # Configure maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  # Configure addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }
  
  # Configure logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Set node config defaults for Autopilot clusters
  node_config {
    # Scopes and OAuth
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
    
    # Enable workload identity on all nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Apply labels to nodes
    labels = merge(var.labels, {
      "cluster-name" = "${var.name_prefix}-gke-cluster"
    })
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  count = var.enable_autopilot ? 0 : 1
  
  name       = "${var.name_prefix}-node-pool"
  project    = var.project_id
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  
  # Configure auto-scaling if enabled
  dynamic "autoscaling" {
    for_each = var.auto_scaling_min != null && var.auto_scaling_max != null ? [1] : []
    content {
      min_node_count = var.auto_scaling_min
      max_node_count = var.auto_scaling_max
    }
  }
  
  # Configure node auto-provisioning if enabled
  dynamic "node_config" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      preemptible  = var.preemptible
      machine_type = var.machine_type
      disk_size_gb = var.disk_size_gb
      disk_type    = var.disk_type
      
      # Scopes and OAuth
      oauth_scopes = [
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/trace.append",
      ]
      
      # Enable workload identity on all nodes
      workload_metadata_config {
        mode = "GKE_METADATA"
      }
      
      # Apply labels to nodes
      labels = merge(var.labels, {
        "cluster-name" = "${var.name_prefix}-gke-cluster"
        "node-pool"    = "${var.name_prefix}-node-pool"
      })
      
      # Apply tags to nodes
      tags = ["gke-node", "${var.name_prefix}-gke"]
    }
  }
  
  # Configure auto-repair
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Configure upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
}
