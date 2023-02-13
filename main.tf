#############################
# Dynamic Variable Creation #
#############################
locals {
  cluster_node_names = formatlist("${var.cluster_name}-%02s", range(1, var.number_of_nodes + 1))
  ami_id = var.aws_image_id == "" || var.aws_image_id == "latest" ? data.aws_ami_ids.rubrik_cloud_cluster.ids[0] : var.aws_image_id
  sg_ids = var.aws_cloud_cluster_nodes_sg_ids == "" ? [module.rubrik_nodes_sg.security_group_id] : concat(var.aws_cloud_cluster_nodes_sg_ids, [module.rubrik_nodes_sg.security_group_id])
  cluster_node_config = {
    "instance_type"           = var.aws_instance_type,
    "ami_id"                  = local.ami_id,
    "sg_ids"                  = local.sg_ids,
    "subnet_id"               = var.aws_subnet_id,
    "key_pair_name"           = local.aws_key_pair_name,
    "disable_api_termination" = var.aws_disable_api_termination,
    "availability_zone"       = data.aws_subnet.rubrik_cloud_cluster.availability_zone,
    "tags"                    = var.aws_tags
  }

  cluster_node_ips = [for i in module.cluster_nodes.instances : i.private_ip]
  cluster_disks = {
    for v in setproduct(local.cluster_node_names, range(var.cluster_disk_count)) :
    "${v[0]}-sd${substr("bcdefghi", v[1], 1)}" => {
      "instance" = v[0],
      "device"   = "/dev/sd${substr("bcdefghi", v[1], 1)}"
      "size"     = var.cluster_disk_size
      "type"     = var.cluster_disk_type
    }
  }
}

data "aws_subnet" "rubrik_cloud_cluster" {
  id = var.aws_subnet_id
}

data "aws_vpc" "rubrik_cloud_cluster" {
  id = data.aws_subnet.rubrik_cloud_cluster.vpc_id
}

data "aws_ami_ids" "rubrik_cloud_cluster" {
  owners = var.aws_ami_owners

  filter {
    name   = "name"
    values = var.aws_ami_filter
  }
}

##############################
# SSH KEY PAIR FOR INSTANCES #
##############################

# Create RSA key of size 4096 bits
resource "tls_private_key" "cc-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key in AWS Secrets Manager
resource "aws_secretsmanager_secret" "cces-private-key" {
  name                    = "${var.cluster_name}-private-key"
  recovery_window_in_days = var.private_key_recovery_window_in_days

  tags = var.aws_tags
}
resource "aws_secretsmanager_secret_version" "cces-private-key-value" {
  secret_id     = aws_secretsmanager_secret.cces-private-key.id
  secret_string = tls_private_key.cc-key.private_key_pem
}

# Optionally create SSH Key
module "aws_key_pair" {
  source          = "terraform-aws-modules/key-pair/aws"
  version         = "~> 2.0.0"

  key_name        = var.aws_key_pair_name == "" ? "${var.cluster_name}.key-pair" : var.aws_key_pair_name
  public_key      = tls_private_key.cc-key.public_key_openssh
}

locals {
  aws_key_pair_name = var.aws_key_pair_name == "" ? module.aws_key_pair.key_pair_name : var.aws_key_pair_name
}

######################################################################
# Create, then configure, the Security Groups for the Rubrik Cluster #
######################################################################
module "rubrik_nodes_sg" {
  source = "terraform-aws-modules/security-group/aws"

  use_name_prefix = true
  name            = var.aws_vpc_cloud_cluster_nodes_sg_name == "" ? "${var.cluster_name}.sg" : var.aws_vpc_cloud_cluster_nodes_sg_name
  description     = "Allow hosts to talk to Rubrik Cloud Cluster and Cluster to talk to itself"
  vpc_id          = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  tags = merge(
    { name = "${var.cluster_name}:sg" },
    var.aws_tags
  )
}

module "rubrik_nodes_sg_rules" {
  source                          = "./modules/rubrik_nodes_sg"
  sg_id                           = module.rubrik_nodes_sg.security_group_id
  rubrik_hosts_sg_id              = module.rubrik_hosts_sg.security_group_id
  cloud_cluster_nodes_admin_cidr  = var.cloud_cluster_nodes_admin_cidr 
  tags = merge(
    { name = "${var.cluster_name}:sg-rule" },
    var.aws_tags
  )
  depends_on = [
    module.rubrik_hosts_sg
  ]
}

module "rubrik_hosts_sg" {
  source = "terraform-aws-modules/security-group/aws"

  use_name_prefix = true
  name            = var.aws_vpc_cloud_cluster_hosts_sg_name == "" ? "${var.cluster_name}.sg" : var.aws_vpc_cloud_cluster_hosts_sg_name
  description     = "Allow Rubrik Cloud Cluster to talk to hosts, and hosts with this security group can talk to cluster"
  vpc_id          = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  tags = merge(
    { name = "${var.cluster_name}:sg" },
    var.aws_tags
  )
}

module "rubrik_hosts_sg_rules" {
  source = "./modules/rubrik_hosts_sg"

  sg_id              = module.rubrik_hosts_sg.security_group_id
  rubrik_nodes_sg_id = module.rubrik_nodes_sg.security_group_id
  tags = merge(
    { name = "${var.cluster_name}:sg-rule" },
    var.aws_tags
  )
  depends_on = [
    module.rubrik_nodes_sg
  ]
}

###############################
# Create EC2 Instances in AWS #
###############################

module "cluster_nodes" {
  source = "./modules/rubrik_aws_instances"

  node_names    = local.cluster_node_names
  node_config   = local.cluster_node_config
  disks         = local.cluster_disks
}

######################################
# Bootstrap the Rubrik Cloud Cluster #
###########################k###########

resource "time_sleep" "wait_for_nodes_to_boot" {
  create_duration = "300s"

  depends_on = [module.cluster_nodes]
}

resource "rubrik_bootstrap" "bootstrap_rubrik" {
  cluster_name            = "${var.cluster_name}"
  admin_email             = "${var.admin_email}"
  admin_password          = "${var.admin_password}"
  management_gateway      = "${cidrhost(data.aws_subnet.rubrik_cloud_cluster.cidr_block, 1)}"
  management_subnet_mask  = "${cidrnetmask(data.aws_subnet.rubrik_cloud_cluster.cidr_block)}"
  dns_search_domain       = "${var.dns_search_domain}"
  dns_name_servers        = "${var.dns_name_servers}"
  ntp_server1_name        = "${var.ntp_server1_name}"
  ntp_server2_name        = "${var.ntp_server2_name}"

  enable_encryption       = false

  node_config = "${zipmap(local.cluster_node_names, local.cluster_node_ips)}"
  timeout     = "${var.timeout}"

  depends_on = [time_sleep.wait_for_nodes_to_boot]

}