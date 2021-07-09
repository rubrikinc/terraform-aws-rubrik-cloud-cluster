#############################
# Dynamic Variable Creation #
#############################
locals {
  cluster_node_names = formatlist("${var.cluster_name}-%s", range(1, var.number_of_nodes + 1))
  cluster_node_ips   = [for i in aws_instance.rubrik_cluster: i.private_ip]
  cluster_disks = {
    for v in setproduct(local.cluster_node_names,range(var.cluster_disk_count)) : 
      "${v[0]}-sd${substr("bcdefghi", v[1], 1)}" => {
        "instance" = v[0],
        "device"   = "/dev/sd${substr("bcdefghi", v[1], 1)}"
      }
  }
}

data "aws_subnet" "rubrik_cloud_cluster" {
  id = var.aws_subnet_id
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

resource "aws_key_pair" "rubrik_cloud_cluster" {
  key_name   = "${var.cluster_name}-key-pair"
  public_key = var.aws_public_key
}

#########################################
# Security Group for the Rubrik Cluster #
#########################################

resource "aws_security_group" "rubrik_cloud_cluster" {
  name        = var.aws_vpc_security_group_name_cloud_cluster_nodes
  description = "Allow hosts to talk to Rubrik Cloud Cluster"
  vpc_id      = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  tags = merge(
    var.aws_tags,
    { "sg:purpose" = "rubrik-cluster-to-self" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_node_ingress" {
  type              = "ingress"
  description       = "Intra cluster communication"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.rubrik_cloud_cluster.id
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.rubrik_cloud_cluster.id
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_cli_admin" {
  type                     = "ingress"
  description              = "CLI administration of the nodes"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rubrik_cloud_cluster.id
  source_security_group_id = aws_security_group.rubrik_hosts.id
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_web_admin" {
  type                     = "ingress"
  description              = "Web administration of the nodes"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rubrik_cloud_cluster.id
  source_security_group_id = aws_security_group.rubrik_hosts.id
}


resource "aws_security_group" "rubrik_hosts" {
  name        = var.aws_vpc_security_group_name_cloud_cluster_hosts
  description = "Allow Rubrik Cloud Cluster to communicate with hosts"
  vpc_id      = data.aws_subnet.rubrik_cloud_cluster.vpc_id
  tags = merge(
    var.aws_tags,
    { "sg:purpose" = "rubrik-cluster-to-self" }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_rbs" {
  type                     = "ingress"
  description              = "Ports for Rubrik Backup Service (RBS)"
  from_port                = 12800
  to_port                  = 12801
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rubrik_hosts.id
  source_security_group_id = aws_security_group.rubrik_cloud_cluster.id
}

###############################
# Create EC2 Instances in AWS #
###############################

resource "aws_instance" "rubrik_cluster" {
  for_each = toset(local.cluster_node_names)
  instance_type = var.aws_instance_type
  ami           = data.aws_ami_ids.rubrik_cloud_cluster.ids[0]
  vpc_security_group_ids = concat([
    aws_security_group.rubrik_cloud_cluster.id
  ], var.aws_security_group_ids)
  subnet_id = var.aws_subnet_id
  key_name  = aws_key_pair.rubrik_cloud_cluster.key_name

  tags = merge({
    Name = each.value },
    var.aws_tags
  )

  disable_api_termination = var.aws_disable_api_termination
  iam_instance_profile    = var.aws_iam_instance_profile
  root_block_device {
    encrypted = true
  }

}

resource "aws_ebs_volume" "ebs_block_device" {
  for_each = local.cluster_disks
  availability_zone = data.aws_subnet.rubrik_cloud_cluster.availability_zone
  type = var.cluster_disk_type
  size = var.cluster_disk_size
  tags = merge(
    {Name = each.key},
    var.aws_tags
  )
  encrypted   = true
}

resource "aws_volume_attachment" "ebs_att" {
  for_each = local.cluster_disks
  device_name = each.value.device
  volume_id   = aws_ebs_volume.ebs_block_device[each.key].id
  instance_id = aws_instance.rubrik_cluster[each.value.instance].id
}