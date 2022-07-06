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
    "iam_instance_profile"    = module.iam_role.aws_iam_instance_profile.name,
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
  create_key_pair = var.create_key_pair ? 1 : 0
}

# RSA key of size 4096 bits
resource "tls_private_key" "cc-key" {
  count = local.create_key_pair
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "cc-key-file" {
  count = local.create_key_pair
  content = tls_private_key.cc-key[0].private_key_pem
  filename = var.private-key-file
  file_permission = "400"
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

module "aws_key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name        = var.aws_key_pair_name == "" ? "${var.cluster_name}.key-pair" : var.aws_key_pair_name
  public_key      = var.aws_public_key == "" ? tls_private_key.cc-key[0].public_key_openssh : var.aws_public_key
  create_key_pair = var.create_key_pair
}

locals {
  aws_key_pair_name = var.aws_key_pair_name == "" ? module.aws_key_pair.key_pair_key_name : var.aws_key_pair_name
}

########################################
# S3 VPC Endpoint for Cloud Cluster ES #
########################################

module "s3_vpc_endpoint" {
  source = "./modules/s3_vpc_endpoint"

  create = var.create_s3_vpc_endpoint
  vpc_id = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  
  tags =  merge(
    { Name = "${var.cluster_name}:ep" },
    var.aws_tags
  )
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
  create          = var.create_cloud_cluster_hosts_sg
  tags = merge(
    { name = "${var.cluster_name}:sg" },
    var.aws_tags
  )
}

module "rubrik_nodes_sg_rules" {
  source                          = "./modules/rubrik_nodes_sg"
  sg_id                           = module.rubrik_nodes_sg.security_group_id
  rubrik_hosts_sg_id              = module.rubrik_hosts_sg.security_group_id
  create                          = var.create_cloud_cluster_hosts_sg
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
  create          = var.create_cloud_cluster_hosts_sg
  tags = merge(
    { name = "${var.cluster_name}:sg" },
    var.aws_tags
  )
}

module "rubrik_hosts_sg_rules" {
  source = "./modules/rubrik_hosts_sg"

  sg_id              = module.rubrik_hosts_sg.security_group_id
  rubrik_nodes_sg_id = module.rubrik_nodes_sg.security_group_id
  create             = var.create_cloud_cluster_hosts_sg
  tags = merge(
    { name = "${var.cluster_name}:sg-rule" },
    var.aws_tags
  )
  depends_on = [
    module.rubrik_nodes_sg
  ]
}


###########################
# Create S3 Bucket in AWS #
###########################
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  create_bucket = var.create_s3_bucket
  bucket = var.s3_bucket_name == "" ? "${var.cluster_name}.bucket-do-not-delete" : var.s3_bucket_name
  acl    = "private"
}

##############################
# Create IAM Role and Policy #
##############################
module "iam_role" {
  source = "./modules/iam_role"

  bucket                = module.s3_bucket
  create                = var.create_iam_role
  role_name             = var.aws_cloud_cluster_iam_role_name == "" ? "${var.cluster_name}.role" : var.aws_cloud_cluster_iam_role_name
  role_policy_name      = var.aws_cloud_cluster_iam_role_policy_name == "" ? "${var.cluster_name}.role-policy" : var.aws_cloud_cluster_iam_role_policy_name
  instance_profile_name = var.aws_cloud_cluster_ec2_instance_profile_name == "" ? "${var.cluster_name}.instance-profile" : var.aws_cloud_cluster_ec2_instance_profile_name
}

###############################
# Create EC2 Instances in AWS #
###############################

module "cluster_nodes" {
  source = "./modules/rubrik_aws_instances"

  node_names  = local.cluster_node_names
  node_config = local.cluster_node_config
  disks       = local.cluster_disks
}