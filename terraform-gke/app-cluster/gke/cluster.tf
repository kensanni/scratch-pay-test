data "google_container_engine_versions" "versions" {
  project  = data.google_project.app_cluster.project_id
  location = var.region
}

resource "random_id" "project_random" {
  prefix      = var.project_prefix
  byte_length = "8"
}

resource "google_project" "app_cluster" {
  count = var.project != "" ? 0 : 1
  name = random_id.project_random.hex
  project_id = random_id.project_random.hex
}

data "google_project" "app_cluster" {
  project_id = var.project != "" ? var.project : google_project.app_cluster[0].project_id
}

resource "google_container_cluster" "app_cluster" {
  provider = google-beta

  name     = "application-cluster"
  project  = data.google_project.app_cluster.project_id
  location = var.region

  network    = google_compute_network.app_cluster_network.self_link
  subnetwork = google_compute_subnetwork.app_cluster_subnetwork.self_link

  initial_node_count = var.kubernetes_nodes_per_zone

  min_master_version = data.google_container_engine_versions.versions.latest_master_version
  node_version       = data.google_container_engine_versions.versions.latest_master_version

  logging_service    = var.kubernetes_logging_service
  monitoring_service = var.kubernetes_monitoring_service

  # Disable legacy ACLs. The default is false, but explicitly marking it false
  # here as well.
  enable_legacy_abac = false

  networking_mode = "VPC_NATIVE"


  node_config {
    machine_type    = var.kubernetes_instance_type
    service_account = google_service_account.app_cluster.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    # Set metadata on the VM to supply more entropy
    metadata = {
      google-compute-enable-virtio-rng = "true"
      disable-legacy-endpoints         = "true"
    }

    labels = {
      service = "app-cluster"
    }

    tags = ["application-cluster"]

    # Protect node metadata
    workload_metadata_config {
      node_metadata = "SECURE"
    }
  }

  # Configure various addons
  addons_config {
    # Enable network policy configurations (like Calico).
    network_policy_config {
      disabled = false
    }
  }

  # Disable basic authentication and cert-based authentication.
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Enable network policy configurations (like Calico) - for some reason this
  # has to be in here twice.
  network_policy {
    enabled = true
  }

  # Set the maintenance window.
  maintenance_policy {
    daily_maintenance_window {
      start_time = var.kubernetes_daily_maintenance_window
    }
  }

  # Allocate IPs in our subnetwork
  ip_allocation_policy {
    cluster_secondary_range_name  = google_compute_subnetwork.app_cluster_subnetwork.secondary_ip_range[0].range_name
    services_secondary_range_name = google_compute_subnetwork.app_cluster_subnetwork.secondary_ip_range[1].range_name
  }

  # Specify the list of CIDRs which can access the master's API
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.kubernetes_master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Configure the cluster to be private (not have public facing IPs)
  private_cluster_config {
    # This field is misleading. This prevents access to the master API from
    # any external IP. While that might represent the most secure
    # configuration, it is not ideal for most setups. As such, we disable the
    # private endpoint (allow the public endpoint) and restrict which CIDRs
    # can talk to that endpoint.
    enable_private_endpoint = false

    enable_private_nodes   = true
    master_ipv4_cidr_block = var.kubernetes_masters_ipv4_cidr
  }

  depends_on = [
    google_project_service.service,
    google_project_iam_member.service-account,
    google_project_iam_member.service-account-custom,
    google_compute_router_nat.app-cluster-nat,
  ]
}