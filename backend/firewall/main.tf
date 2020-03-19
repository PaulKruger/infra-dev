## VPC firewall
# Variables
variable "location" {
  description = "Location for creation"
}

variable "resource_group" {
  description = "Azure resource group"
}

variable "vpc_name" {
  description = "network name"
}

variable "ip_cidr_range" {
  description = "subnet range"
}

variable "subnet_id" {
  description = "Id of the subnet to add to the firewall"
}

variable "firewall_subnet_prefix" {
  description = "Prefix for the firewall"
}

variable "tafi_vpn_address" {
  description = "TAFi VPN Address"
}

# main tf code
# firewall subnet
resource "azurerm_subnet" "subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group
  virtual_network_name = var.vpc_name
  address_prefix       = var.firewall_subnet_prefix
}

# public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "tafi-dev_public_ip"
  location            = var.location
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
}

# firewall
resource "azurerm_firewall" "firewall" {
  name    = "tafi-dev-firewall"
  location = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name = "tafi-dev-firewall-configuration"
    subnet_id = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id

  }
}

# Firewall Rules
resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "tafi-dev-firewall-rule-collection"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = var.resource_group
  priority            = 100
  action              = "Allow"

  rule {
    name = "tafi-dev-firewall-ingress-rule-1"
    source_addresses = [var.ip_cidr_range, var.tafi_vpn_address]
    destination_ports = ["80", "443", "8500"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
  rule {
    name = "tafi-dev-firewall-ingress-rule-2"
    source_addresses = [var.ip_cidr_range, var.tafi_vpn_address]
    destination_ports = ["*"]
    destination_addresses = ["*"]
    protocols = ["ICMP","UDP"]
  }
  rule {
    name = "tafi-dev-firewall-egress-rule-1"
    source_addresses = ["0.0.0.0/0"]
    destination_ports = ["*"]
    destination_addresses = ["*"]
    protocols = ["ICMP"]
  }
  rule {
    name = "tafi-dev-firewall-egress-rule-2"
    source_addresses = ["0.0.0.0/0"]
    destination_ports = ["80", "443"]
    destination_addresses = ["*"]
    protocols = ["TCP"]
  }
}