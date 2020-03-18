## GKE Cluster configuration

# Variables
variable "location" {
  description = "Azure location"
}

variable "az_resource_group" {
  description = "Azure resource group"
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
resource "azurerm_kubernetes_cluster" "primary" {
  name = "tafi-dev-kubernetes-cluster"
  resource_group_name = var.az_resource_group
  location = var.location
  dns_prefix = "tafi-dev-kubernetes-cluster-dns"
  agent_pool_profile {
    name = "agntplpfl"
    vm_size = "B2s"
  }
  service_principal {
    client_id = var.gke_username
    client_secret = var.gke_password
  }
  tags = {
    Environment = var.gke_label
  }
}

# Output
/*
output "endpoint" {
  value       = azurerm_kubernetes_cluster.primary.endpoint
  description = "Endpoint for accessing the master node"
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.primary.master_auth.0.client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.primary.master_auth.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.primary.endpoint
  sensitive = true
}
*/