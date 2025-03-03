###########################################
# GCP provider configuration
###########################################

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.21"
    }
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {
  project_id = var.gcp_project
}

###########################################
# Activate service APIs
###########################################

# Cloud Run - Enables the Cloud Run service for the project
resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# SQL Component - Enables the SQL Component service for the project
resource "google_project_service" "sql-component" {
  service            = "sql-component.googleapis.com"
  disable_on_destroy = false
}

# SQL Admin - Enables the SQL Admin service for the project
resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

# Cloud Build - Enables the Cloud Build service for the project
resource "google_project_service" "cloudbuild" {
  service            = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# Secret Manager - Enables the Secret Manager service for the project
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# IAM API - Enables the IAM API service for the project
resource "google_project_service" "iamapi" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "serviceusage" {
  service            = "serviceusage.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudkms" {
  service            = "cloudkms.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "redis" {
  service            = "redis.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "vpcaccess" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}
resource "google_project_service" "dlp" {
  service            = "dlp.googleapis.com"
  disable_on_destroy = false
}
