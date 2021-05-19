resource "google_compute_address" "app_cluster_nat" {
  count   = 2
  name    = "application-cluster-nat-external-${count.index}"
  project = data.google_project.app_cluster.project_id
  region  = var.region

  depends_on = [google_project_service.service]
}

resource "google_compute_network" "app_cluster_network" {
  name                    = "application-cluster-network"
  project                 = data.google_project.app_cluster.project_id
  auto_create_subnetworks = false

  depends_on = [google_project_service.service]
}


resource "google_compute_subnetwork" "app_cluster_subnetwork" {
  name          = "application-cluster-subnetwork"
  project       = data.google_project.app_cluster.project_id
  network       = google_compute_network.app_cluster_network.self_link
  region        = var.region
  ip_cidr_range = var.kubernetes_network_ipv4_cidr

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "application-cluster-pods"
    ip_cidr_range = var.kubernetes_pods_ipv4_cidr
  }

  secondary_ip_range {
    range_name    = "application-cluster-svcs"
    ip_cidr_range = var.kubernetes_services_ipv4_cidr
  }
}

resource "google_compute_router" "app_cluster_router" {
  name    = "application-cluster-router"
  project = data.google_project.app_cluster.project_id
  region  = var.region
  network = google_compute_network.app_cluster_network.self_link

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "app-cluster-nat" {
  name    = "application-cluster-nat-1"
  project = data.google_project.app_cluster.project_id
  router  = google_compute_router.app_cluster_router.name
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.app_cluster_nat.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.app_cluster_subnetwork.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      google_compute_subnetwork.app_cluster_subnetwork.secondary_ip_range[0].range_name,
      google_compute_subnetwork.app_cluster_subnetwork.secondary_ip_range[1].range_name,
    ]
  }
}

resource "google_compute_firewall" "allow_internal_network" {
  name    = "allow-internal-network-tn"
  network = google_compute_network.app_cluster_network.name
  source_ranges = [var.internal_source_ranges]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-tn"
  network = google_compute_network.app_cluster_network.name
  source_ranges = [var.internal_source_ranges]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}