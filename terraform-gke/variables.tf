variable "region" {
  type        = string
  default     = "us-east1"
  description = "Region in which to create the cluster"
}

variable "project" {
  type        = string
  description = "Project ID where Terraform is authenticated to run to create additional projects. If provided, Terraform will create the GKE and Vault cluster inside this project. If not given, Terraform will generate a new project."
}

variable "credentials" {
  type        = string
  description =  "Service account file for authenticating with the GCP"
}

variable "project_prefix" {
  type        = string
  default     = "test-"
  description = "String value to prefix the generated project ID with."
}

variable "kubernetes_instance_type" {
  type        = string
  default     = "n1-standard-2"
  description = "Instance type to use for the nodes."
}

variable "service_account_iam_roles" {
  type = list(string)
  default = [
    "roles/container.admin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.admin"
  ]
  description = "List of IAM roles to assign to the service account."
}

variable "service_account_custom_iam_roles" {
  type        = list(string)
  default     = []
  description = "List of arbitrary additional IAM roles to attach to the service account on the Application cluster nodes."
}

variable "project_services" {
  type = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
  description = "List of API services to enable on the project."
}

#
# Kubernetes options
# ------------------------------
variable "kubernetes_nodes_per_zone" {
  type        = number
  default     = 1
  description = "Number of nodes to deploy in each zone of the Kubernetes cluster. For example, if there are 4 zones in the region and num_nodes_per_zone is 2, 8 total nodes will be created."
}

variable "kubernetes_daily_maintenance_window" {
  type        = string
  default     = "06:00"
  description = "Maintenance window for GKE."
}

variable "kubernetes_logging_service" {
  type        = string
  default     = "logging.googleapis.com/kubernetes"
  description = "Name of the logging service to use. By default this uses the new Stackdriver GKE beta."
}

variable "kubernetes_monitoring_service" {
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
  description = "Name of the monitoring service to use. By default this uses the new Stackdriver GKE beta."
}

variable "kubernetes_network_ipv4_cidr" {
  type        = string
  default     = "10.0.96.0/22"
  description = "IP CIDR block for the subnetwork. This must be at least /22 and cannot overlap with any other IP CIDR ranges."
}

variable "kubernetes_pods_ipv4_cidr" {
  type        = string
  default     = "10.0.92.0/22"
  description = "IP CIDR block for pods. This must be at least /22 and cannot overlap with any other IP CIDR ranges."
}

variable "kubernetes_services_ipv4_cidr" {
  type        = string
  default     = "10.0.88.0/22"
  description = "IP CIDR block for services. This must be at least /22 and cannot overlap with any other IP CIDR ranges."
}

variable "kubernetes_masters_ipv4_cidr" {
  type        = string
  default     = "10.0.82.0/28"
  description = "IP CIDR block for the Kubernetes master nodes. This must be exactly /28 and cannot overlap with any other IP CIDR ranges."
}

variable "internal_source_ranges" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_master_authorized_networks" {
  type = list(object({
    display_name = string
    cidr_block   = string
  }))

  default = [
    {
      display_name = "Anyone"
      cidr_block   = "0.0.0.0/0"
    }
  ]

  description = "List of CIDR blocks to allow access to the Kubernetes master's API endpoint. This is specified as a slice of objects, where each object has a display_name and cidr_block attribute. The default behavior is to allow anyone (0.0.0.0/0) access to the endpoint. You should restrict access to external IPs that need to access the Kubernetes cluster."
}
