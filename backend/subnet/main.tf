## Subnet

# Variables
variable "region" {
  description = "region"
}

variable "vpc_name" {
  description = "network name"
}

variable "subnet_cidr" {
  description = "subnet range"
}

# main tf code

resource "google_compute_subnetwork" "subnet" {
  name          = "tafi-dev-subnet"
  region        = "${var.region}"
  network       = "${var.vpc_name}"
  ip_cidr_range = "${var.subnet_cidr}"
}

# Output
output "ip_cidr_range" {
  value       = "${google_compute_subnetwork.subnet.ip_cidr_range}"
  description = "created CICDR range"
}

output "subnet_name" {
  value       = "${google_compute_subnetwork.subnet.name}"
  description = "created subnet name"
}
