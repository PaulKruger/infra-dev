## GKE Cluster configuration

# Variables
variable "location" {
  description = "Azure location"
}

variable "az_resource_group" {
  description = "Azure resource group"
}

variable "az_node_machine_type" {
  description = "Machine Type for Azure"
}

variable "kubernetes_cluster_name" {
  description = "Name of the kubernetes cluster"
}

variable "az_label" {
  description = "cluster env labels"
}

variable "subnet_id" {
  description = "The identifier for the subnet"
}

# main tf code
resource "azuread_application" "aks_sp" {
  name                       = var.kubernetes_cluster_name
  homepage                   = "https://${var.kubernetes_cluster_name}"
  identifier_uris            = ["https://${var.kubernetes_cluster_name}"]
  reply_urls                 = ["https://${var.kubernetes_cluster_name}"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
}

resource "azuread_service_principal" "aks_sp" {
  application_id = azuread_application.aks_sp.application_id
}

resource "random_password" "aks_sp_pwd" {
  length  = 16
  special = true
}

resource "azuread_service_principal_password" "aks_sp_pwd" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp_pwd.result
  end_date             = "2024-01-01T01:02:03Z"
}


resource "azurerm_kubernetes_cluster" "primary" {
  name = var.kubernetes_cluster_name
  resource_group_name = var.az_resource_group
  location = var.location
  dns_prefix = "tafi-dev-kubernetes-cluster-dns"

  default_node_pool {
    name = "agentpool"
    vm_size = var.az_node_machine_type
    vnet_subnet_id = var.subnet_id
    node_count = 2
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = azuread_application.aks_sp.application_id
    client_secret = random_password.aks_sp_pwd.result
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }

  provisioner "local-exec" {
    # Load credentials to local environment so subsequent kubectl commands can be run
    command = <<EOS
      az aks get-credentials --resource-group var.az_resource_group --name self.name;
EOS

  }


  tags = {
    Environment = var.az_label
  }
}

# Output

output "username" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.username
  sensitive = true
}
output "password" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.password
  sensitive = true
}
output "host" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.host
  sensitive = true
}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.client_certificate
  sensitive = true
}
output "client_key" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.client_key
  sensitive = true
}
output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.cluster_ca_certificate
  sensitive = true
}
