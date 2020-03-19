## Consul cluster
variable "username" {}
variable "password" {}
variable "host" {}
variable client_certificate {}
variable client_key {}
variable cluster_ca_certificate {}

# main tf code
provider "kubernetes" {
  host     = var.host
  username = var.username
  password = var.password

  client_certificate     = base64decode(var.client_certificate)
  client_key             = base64decode(var.client_key)
  cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
}

module "services" {
  source = "./services"
}

module "cluster" {
  source = "./stateful"
}

module "agent" {
  source = "./daemonset"
}

# output

