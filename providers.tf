terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    rubrik = {
      source   = "rubrikinc/rubrik/rubrik"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "rubrik" {
#  node_ip  = "${module.cluster_nodes.instances.0.private_ip}"
  node_ip  = local.cluster_node_ips.0
  username = ""
  password = ""
}