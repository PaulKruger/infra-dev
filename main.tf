# main teraform code
#Azure Setup
terraform {
  backend "terraform" {
    resource_group_name   = "TAFiDevStack"
    storage_account_name  = "tafiterraformdev2"
    container_name        = "tafiterraformdev"
    key                   = "znLXpx2j4hDqXtDPcAzfChvUO20wA5mgqj84Ab6uo9+ze2NPnie3VjyMwI2XZMKF50XbOv6cu452CjB54PIWxg=="
  }
}

provider "azurerm" {
  version = "~>1.32.0"
}