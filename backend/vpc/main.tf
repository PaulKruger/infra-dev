# Create VPC
resource "google_compute_network" "vpc" {
  name                    = "tafi-dev-vpc"
  auto_create_subnetworks = "false"
}

# VPC outputs
output "vpc_name" {
  value       = "${google_compute_network.vpc.name}"
  description = "The unique name of the network"
}

output "self_link" {
  value       = "${google_compute_network.vpc.self_link}"
  description = "The URL of the created resource"
}
