## GKE Cluster configuration

# Variables
variable "region" {
  description = "region"
}

variable "min_master_version" {
  description = "gke node version"
}

variable "node_version" {
  description = "gke node versoin"
}

variable "gke_num_nodes" {
  description = "num of nodes in each GKE cluster zone"
}

variable "vpc_name" {
  description = "vpc name"
}

variable "subnet_name" {
  description = "subnet name"
}

variable "gke_node_machine_type" {
  description = "machine type of GKE nodes"
}

variable gke_label {
  description = "cluster env labels"
}

variable "gke_username" {
  description = "gke username"
}

variable "gke_password" {
  description = "gke password"
}

# main tf code
resource "google_container_cluster" "primary" {
  name = "tafi-dev-cluster"
  zone = "${var.region}-c"

  # additional_zones = [
  #   "${var.region}-a",
  #   "${var.region}-f",
  # ]

  min_master_version = "${var.min_master_version}"
  node_version       = "${var.node_version}"
  enable_legacy_abac = false
  initial_node_count = "${var.gke_num_nodes}"
  network            = "${var.vpc_name}"
  subnetwork         = "${var.subnet_name}"
  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = false
    }
  }
  master_auth {
    username = "${var.gke_username}"
    password = "${var.gke_password}"

    client_certificate_config = {
      issue_client_certificate = false
    }
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
    ]

    labels {
      env = "${var.gke_label}"
    }

    disk_size_gb = 10
    machine_type = "${var.gke_node_machine_type}"
    tags         = ["gke-node"]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Output
output "endpoint" {
  value       = "${google_container_cluster.primary.endpoint}"
  description = "Endpoint for accessing the master node"
}

output "client_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${google_container_cluster.primary.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${google_container_cluster.primary.endpoint}"
  sensitive = true
}
