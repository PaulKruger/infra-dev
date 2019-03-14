## VPC firewall

# Variables
variable "vpc_name" {
  description = "network name"
}

variable "ip_cidr_range" {
  description = "subnet range"
}

# main tf code
resource "google_compute_firewall" "firewall-ing" {
  name    = "tafi-dev-firewall-ing"
  network = "${var.vpc_name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8500"]
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["${var.ip_cidr_range}"]
}

# only allow vpn.tafi.io access, ingress rules
resource "google_compute_firewall" "firewall-vpn-ing" {
  name    = "tafi-dev-firewall-vpn-ing"
  network = "${var.vpc_name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8500"]
  }

  allow {
    protocol = "udp"
  }

  # 35.232.216.163 - vpn.tafi.io
  source_ranges = ["35.232.216.163"]
}

# Create a firewall rule that allows external SSH, ICMP, and HTTPS:
resource "google_compute_firewall" "firewall-exg" {
  name    = "tafi-dev-firewall-exg"
  network = "${var.vpc_name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
