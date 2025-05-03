# Network Module
module "network" {
  source = "./modules/network"

  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  vpc_cidr       = var.vpc_cidr
  subnet_cidrs   = var.subnet_cidrs
  application_name = var.application_name
}

# Security Module
module "security" {
  source = "./modules/security"

  project_id     = var.project_id
  environment    = var.environment
  application_name = var.application_name
  vpc_id         = module.network.vpc_id
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  application_name = var.application_name
  kms_crypto_key = var.kms_crypto_key
  service_account_email = module.security.service_account_email
}

# Database Module
module "database" {
  source = " ./modules/database"

  project_id     = var.project_id
  region         = var.region
  environment    = var.environment
  application_name = var.application_name
  vpc_id         = module.network.vpc_id
  subnet_id      = module.network.data_subnet_id
}

# Compute Module
module "compute" {
  source = "./modules/compute"

  project_id     = var.project_id
  region         = var.region
  zone           = var.zone
  environment    = var.environment
  application_name = var.application_name
  vpc_id         = module.network.vpc_id
  web_subnet_id  = module.network.web_subnet_id
  app_subnet_id  = module.network.app_subnet_id
  
  # Pass dependencies from other modules
  database_connection = module.database.connection_name
  storage_bucket_name = module.storage.primary_bucket_name
}