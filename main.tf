# Variables
variable "location" {
  default     = "eastus"
  description = "Region in which the resources will be deployed"
}

variable "az_resource_group" {
  default     = "TAFiDevStack"
  description = "Resource Group in Azure to add resources to"
}

variable "az_subscription_id" {
  default = "5c10115a-819f-428b-b7a9-d607a2951d2b"
  description = "The subscription identifier."
}

variable "tafi_vpn_address" {
  default = "35.232.216.163"
  description = "VPN Provided by TAFI"
}

variable "address_prefix" {
  default     = "10.10.0.0/24"
  description = "Subnet address prefix"
}

variable "firewall_subnet_prefix" {
  default     = "10.10.1.0/24"
  description = "Subnet address prefix"
}

variable "kubernetes_cluster_name" {
  default = "dev-kubernetes-cluster"
  description = "Kubernetes cluster name"
}

variable "gke_username" {
  default     = "p.kruger@craneware.com"
  description = "gke username"
}

variable "gke_password" {
  default     = "thisIz!taf1_Pw@!"
  description = "gke password"
}

# main teraform code
#Azure Setup
terraform {
  backend "azurerm" {
    resource_group_name   = "TAFiDevStack"
    storage_account_name  = "tafiterraformdev2"
    container_name        = "tafiterraformstatedev"
    key                   = "znLXpx2j4hDqXtDPcAzfChvUO20wA5mgqj84Ab6uo9+ze2NPnie3VjyMwI2XZMKF50XbOv6cu452CjB54PIWxg=="
  }
}

provider "azurerm" {
  version = "~>2.0.0"
  features {}
}

# setting up backend - vpc, subnet and firewall
module "vpc" {
  location       = var.location
  address_prefix = var.address_prefix
  firewall_subnet_prefix = var.firewall_subnet_prefix
  source         = "./backend/vpc"
}

module "subnet" {
  source         = "./backend/subnet"
  resource_group = var.az_resource_group
  vpc_name       = module.vpc.vpc_name
  address_prefix = var.address_prefix
}
/*
module "firewall" {
  source        = "./backend/firewall"
  vpc_name      = module.vpc.vpc_name
  resource_group = var.az_resource_group
  location       = var.location
  ip_cidr_range = module.subnet.ip_cidr_range
  subnet_id    = module.subnet.subnet_id
  firewall_subnet_prefix    = var.firewall_subnet_prefix
  tafi_vpn_address = var.tafi_vpn_address
}
*/
# setting up kubernetes cluster
module "kubernetes" {
  source                = "./kubernetes"
  location              = var.location
  az_resource_group        = var.az_resource_group
  kubernetes_cluster_name = var.kubernetes_cluster_name
  az_node_machine_type = "Standard_B2s"
  az_label             = "tafi-dev"
  #Subnet
  subnet_id = module.subnet.subnet_id
}

# setting up consul cluster
module "consul" {
  source             = "./consul"
  # Credentials
  host     = module.kubernetes.host
  username = module.kubernetes.username
  password = module.kubernetes.password
  client_certificate     = module.kubernetes.client_certificate
  client_key             = module.kubernetes.client_key
  cluster_ca_certificate = module.kubernetes.cluster_ca_certificate
}
