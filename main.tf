# Configure the Google Cloud provider
terraform {
  backend "gcs" {
    bucket = "tafi-tf-dev"
  }
}

# Variables
variable "region" {
  default     = "us-central1"
  description = "region"
}

variable "gke_username" {
  default     = "tafiadmin"
  description = "gke username"
}

variable "gke_password" {
  default     = "thisIz!taf1_Pw@!"
  description = "gke password"
}

# main tf code

provider "google" {
  version = "~> 1.16"
  project = "tafi-dev"
  region  = "${var.region}"
}

# setting up backend - vpc, subnet and firewall
module "vpc" {
  source = "./backend/vpc"
}

module "subnet" {
  source      = "./backend/subnet"
  region      = "${var.region}"
  vpc_name    = "${module.vpc.vpc_name}"
  subnet_cidr = "10.10.0.0/24"
}

module "firewall" {
  source        = "./backend/firewall"
  vpc_name      = "${module.vpc.vpc_name}"
  ip_cidr_range = "${module.subnet.ip_cidr_range}"
}

# setting up gke cluster
module "gke" {
  source                = "./gke"
  region                = "${var.region}"
  min_master_version    = "1.12.5-gke.5"
  node_version          = "1.12.5-gke.5"
  gke_num_nodes         = 5
  vpc_name              = "${module.vpc.vpc_name}"
  subnet_name           = "${module.subnet.subnet_name}"
  gke_node_machine_type = "n1-standard-1"
  gke_label             = "tafi-dev"
  gke_username          = "${var.gke_username}"
  gke_password          = "${var.gke_password}"
}

# setting up consul cluster

module "consul" {
  source   = "./consul"
  host     = "${module.gke.host}"
  username = "${var.gke_username}"
  password = "${var.gke_password}"

  client_certificate     = "${module.gke.client_certificate}"
  client_key             = "${module.gke.client_key}"
  cluster_ca_certificate = "${module.gke.cluster_ca_certificate}"
}

module "drone" {
  source = "./drone"
}

module "tafi-router" {
  source = "./tafi-router"
}

module "rmq" {
  source = "./rmq"
}

module "postgres" {
  source = "./postgres"
}

module "mirth-light" {
  source = "./mirth-light"
}

module "mirth-heavy" {
  source = "./mirth-heavy"
}
