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
    resource_group_name   =  var.az_resource_group
    storage_account_name  = "tafiterraformdev"
    container_name        = "tafiterraformstatedev"
    key                   = "jL1qNh7XDiDbtIWFyzMzn5euvxIB2Eet/iIf+t3bzEEGibBmYRIaDCkbTwoOVVEqFe+TlcJzyzMIaWVVrxa/6Q=="
  }
}

provider "azurerm" {
  version = "~>1.32.0"
  subscription_id = var.az_subscription_id
}

#Setup Resource Group
resource "azurerm_resource_group" "resource_group" {
  name     = var.az_resource_group
  location = var.location
}

#Setup Storage Account
resource "azurerm_storage_account" "storage_account" {
  name                = "tafiterraformdev"
  resource_group_name = var.az_resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"


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

# setting up kubernetes cluster
module "kubernetes" {
  source                = "./kubernetes"
  location              = var.location
  az_resource_group        = var.az_resource_group
  min_master_version    = "1.12.5-gke.5"
  node_version          = "1.12.5-gke.5"
  gke_num_nodes         = 5
  vpc_name              = module.vpc.vpc_name
  subnet_name           = module.subnet.subnet_name
  gke_node_machine_type = "n1-standard-1"
  gke_label             = "tafi-dev"
  gke_username          = var.gke_username
  gke_password          = var.gke_password
}
