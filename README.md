# gcp-terraform-tier3

Terraform GCP Tier 3 Application Infrastructure
This repository contains Terraform modules for deploying a tier 3 application infrastructure on Google Cloud Platform.
Architecture
This infrastructure provides a complete tier 3 application stack:

Networking layer with VPC, subnets, and Cloud NAT
GKE cluster for container orchestration
Cloud SQL for database management
Redis for caching
Cloud Storage for object storage
IAM for security and access management

Module Structure

networking: VPC, subnets, Cloud NAT, and firewall rules
gke: Kubernetes cluster and node pools
database: Cloud SQL instance and database
cache: Redis instance
storage: Cloud Storage buckets
iam: Service accounts and IAM bindings

Prerequisites

Terraform v1.0+
Google Cloud Platform account and project
Service account with appropriate permissions
gcloud CLI configured (optional, for local development)

Usage

Clone this repository
Navigate to the repository directory
Initialize Terraform:
terraform init

Set up your environment variables or use the provided tfvars files:
terraform plan -var-file=environments/dev.tfvars

Apply the Terraform configuration:
terraform apply -var-file=environments/dev.tfvars


Environment Configuration
This module supports multiple environments through variable files:

environments/dev.tfvars: Development environment
environments/staging.tfvars: Staging environment
environments/prod.tfvars: Production environment

GitHub Actions Integration
This repository includes a GitHub Actions workflow for automated Terraform validation, planning, and deployment. The workflow is triggered on pull requests and pushes to the main branch.
Required GitHub Secrets

GCP_PROJECT_ID: Your Google Cloud project ID
GCP_SA_KEY: Service account key with permissions to deploy resources

Contributing

Fork the repository
Create a feature branch
Commit your changes
Push to the branch
Create a new Pull Request