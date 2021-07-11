#############################
# Dynamic Variable Creation #
#############################
locals {
  cluster_name = var.environment == "" ? var.cluster_name : "${var.environment}.${var.cluster_name}"
  cluster_node_names = formatlist("${local.cluster_name}-%01s", range(1, var.number_of_nodes + 1))
  cluster_node_config = {
    "instance_type" = var.aws_instance_type,
    "ami_id" = data.aws_ami_ids.rubrik_cloud_cluster.ids[0],
    "sg_ids" = concat(var.aws_cloud_cluster_nodes_sg_ids, [module.rubrik_nodes_sg.security_group_id]),
    "subnet_id" = var.aws_subnet_id,
    "key_pair_name" = local.aws_key_pair_name,
    "disable_api_termination" = var.aws_disable_api_termination,
    "iam_instance_profile" = module.iam_role.aws_iam_instance_profile.name,
    "availability_zone" = data.aws_subnet.rubrik_cloud_cluster.availability_zone,
    "tags" = var.aws_tags
  }
  cluster_node_ips   = [for i in module.cluster_nodes.instances: i.private_ip]
  cluster_disks = {
    for v in setproduct(local.cluster_node_names,range(var.cluster_disk_count)) : 
      "${v[0]}-sd${substr("bcdefghi", v[1], 1)}" => {
        "instance" = v[0],
        "device"   = "/dev/sd${substr("bcdefghi", v[1], 1)}"
        "size" = var.cluster_disk_size
        "type" = var.cluster_disk_type
      }
  }
  cluster_tag = var.environment_tag == "" ? local.cluster_name : "${var.environment_tag}:${local.cluster_name}"
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

  key_name   = var.aws_key_pair_name == "" ? "${local.cluster_name}.key-pair" : var.aws_key_pair_name
  public_key = var.aws_public_key
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
  #route_table_ids = [data.aws_vpc.rubrik_cloud_cluster.main_route_table_id]
  #endpoint_name = (var.s3_vpc_endpoint_name == "" ? "${local.cluster_name}.vpc-ep" : var.s3_vpc_endpoint_name)
  tags = merge(
    var.aws_tags
  )
}


######################################################################
# Create, then configure, the Security Groups for the Rubrik Cluster #
######################################################################
module "rubrik_nodes_sg" {
  source = "terraform-aws-modules/security-group/aws"

  use_name_prefix = true
  name = var.aws_vpc_cloud_cluster_nodes_sg_name == "" ? "${local.cluster_name}.sg" : var.aws_vpc_cloud_cluster_nodes_sg_name
  description = "Allow hosts to talk to Rubrik Cloud Cluster and Cluster to talk to itself"
  vpc_id      = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  create = var.create_aws_rubrik_hosts_sg
  tags = merge(
    {name = "${local.cluster_tag}:sg"},
    var.aws_tags
  )
}

module "rubrik_nodes_sg_rules" {
  source = "./modules/rubrik_nodes_sg"
  sg_id = module.rubrik_nodes_sg.security_group_id
  rubrik_hosts_sg_id = module.rubrik_hosts_sg.security_group_id
  create = var.create_aws_rubrik_hosts_sg
  tags = merge(
    {name = "${local.cluster_tag}:sg-rule"},
    var.aws_tags
  )
  depends_on = [
    module.rubrik_hosts_sg
  ]
}

module "rubrik_hosts_sg" {
  source = "terraform-aws-modules/security-group/aws"

  use_name_prefix = true
  name = var.aws_vpc_cloud_cluster_nodes_sg_name == "" ? "${local.cluster_name}.sg" : var.aws_vpc_cloud_cluster_nodes_sg_name
  description = "Allow Rubrik Cloud Cluster to talk to hosts, and hosts with this security group can talk to cluster"
  vpc_id      = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  create = var.create_aws_rubrik_hosts_sg
  tags = merge(
    {name = "${local.cluster_tag}:sg"},
    var.aws_tags
  )
}

module "rubrik_hosts_sg_rules" {
  source = "./modules/rubrik_hosts_sg"

  sg_id = module.rubrik_hosts_sg.security_group_id
  rubrik_nodes_sg_id = module.rubrik_nodes_sg.security_group_id
  create = var.create_aws_rubrik_hosts_sg
  tags = merge(
    {name = "${local.cluster_tag}:sg-rule"},
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

  bucket = (var.s3_bucket_name == "" ? "${local.cluster_name}.bucket-DO-NOT-DELETE" : var.s3_bucket_name)
  acl    = "private"
}

##############################
# Create IAM Role and Policy #
##############################
module "iam_role" {
  source = "./modules/iam_role"

  bucket = module.s3_bucket.s3_bucket_id
  create = var.create_iam_role
  role_name = "thingy"
  role_policy_name = "thingy-pol"
  instance_profile_name = "thingy-profile"
} 

###############################
# Create EC2 Instances in AWS #
###############################

module "cluster_nodes" {
  source = "./modules/rubrik_aws_instances"
  
  node_names = local.cluster_node_names
  node_config = local.cluster_node_config
  disks = local.cluster_disks
}