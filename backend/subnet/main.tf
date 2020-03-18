## Subnet

# Variables
variable "resource_group" {
  description = "Azure resource group"
}

variable "vpc_name" {
  description = "network name"
}

variable "address_prefix" {
  description = "subnet range"
}

# main tf code
resource "azurerm_subnet" "subnet" {
  name                 = "tafi-dev-subnet"
  resource_group_name  = var.resource_group
  virtual_network_name = var.vpc_name
  address_prefix       = var.address_prefix
}

# Output
output "ip_cidr_range" {
  value       = azurerm_subnet.subnet.address_prefix
  description = "created CICDR range"
}

output "subnet_name" {
  value       = azurerm_subnet.subnet.name
  description = "created subnet name"
}

output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
