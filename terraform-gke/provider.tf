terraform {
  required_version = ">= 0.12"

  required_providers {
    google = "~> 3.0"
  }
}

provider  "google" {
  region  = var.region
  project = var.project
  credentials = file(var.credentials)
}

provider "google-beta" {
  region  = var.region
  project = var.project
  credentials = file(var.credentials)
}

