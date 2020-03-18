# Variables
variable "location" {
  description = "Location for creation"
}

variable "address_prefix" {
  description = "Address prefix to assign"
}

variable "firewall_subnet_prefix" {
  description = "Prefix for the firewall"
}

# Create VPC
resource "azurerm_virtual_network" "vpc" {
  name                = "tafi-dev-vpc"
  location            = var.location
  address_space       = [var.address_prefix, var.firewall_subnet_prefix]
  resource_group_name = "TAFiDevStack"
}

# VPC outputs
output "vpc_name" {
  value       = azurerm_virtual_network.vpc.name
  description = "The unique name of the network"
}
