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
    resource_group_name   = "TAFiDevStack"
    storage_account_name  = "tafiterraformdev2"
    container_name        = "tafiterraformstatedev"
    key                   = "znLXpx2j4hDqXtDPcAzfChvUO20wA5mgqj84Ab6uo9+ze2NPnie3VjyMwI2XZMKF50XbOv6cu452CjB54PIWxg=="
  }
}

provider "azurerm" {
  version = "~>1.32.0"
}