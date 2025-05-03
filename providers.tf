###################################################
# providers.tf
###################################################

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Beta provider for features not yet in GA
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}