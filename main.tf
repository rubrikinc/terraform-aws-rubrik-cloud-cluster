provider "aws" {
  region = var.aws_region
}

#############################
# Dynamic Variable Creation #
#############################
resource "null_resource" "create_cluster_node_name" {
  count = "${var.number_of_nodes}"

  triggers = {
    node_number = "${count.index + 1}"
  }
}

locals {
  cluster_node_name = "${formatlist("${var.cluster_name}-%s", null_resource.create_cluster_node_name.*.triggers.node_number)}"

  cluster_node_ips = "${aws_instance.rubrik_cluster.*.private_ip}"
}

data "aws_subnet" "rubrik_cloud_cluster" {
  id = "${var.aws_subnet_id}"
}

  owners = ["447546863256"] # Rubrik

  filter {
    name   = "name"
    values = ["rubrik-*"]
  }
}

#########################################
# Security Group for the Rubrik Cluster #
#########################################

resource "aws_security_group" "rubrik_cloud_cluster" {
  name        = "${var.aws_vpc_security_group_name_cloud_cluster_nodes}"
  description = "Allow hosts to talk to Rubrik Cloud Cluster"
  vpc_id      = "${data.aws_subnet.rubrik_cloud_cluster.vpc_id}"

  ingress {
    description      = "Intra cluster communication"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    self             = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "rubrik_hosts" {
  name        = "${var.aws_vpc_security_group_name_cloud_cluster_hosts}"
  description = "Allow Rubrik Cloud Cluster to communicate with hosts"
  vpc_id      = "${data.aws_subnet.rubrik_cloud_cluster.vpc_id}"

  ingress {
    description      = "Ports for Rubrik Backup Service (RBS)"
    from_port        = 12800
    to_port          = 12801
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.rubrik_cloud_cluster.id}"]
  }
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_cli_admin" {
  type              = "ingress"
  description       = "CLI administration of the nodes"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.rubrik_cloud_cluster.id}"
  source_security_group_id = "${aws_security_group.rubrik_hosts.id}"
}

resource "aws_security_group_rule" "rubrik_cloud_cluster_web_admin" {
  type              = "ingress"
  description       = "Web administration of the nodes"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.rubrik_cloud_cluster.id}"
  source_security_group_id = "${aws_security_group.rubrik_hosts.id}"
}

###############################
# Create EC2 Instances in AWS #
###############################

resource "aws_instance" "rubrik_cluster" {
  count                  = "${var.number_of_nodes}"
  instance_type          = "${var.aws_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.rubrik_cloud_cluster.id}"]
  subnet_id              = "${var.aws_subnet_id}"

  tags = {
    Name = "${element(local.cluster_node_name, count.index)}"
  }

  disable_api_termination = "${var.aws_disable_api_termination}"

  root_block_device {
    encrypted = true
  }
  
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "st1"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdc"
    volume_type = "st1"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdd"
    volume_type = "st1"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }
}

######################################
# Bootstrap the Rubrik Cloud Cluster #
######################################

provider "rubrik" {
  node_ip  = "${aws_instance.rubrik_cluster.0.private_ip}"
  username = ""
  password = ""
}

resource "rubrik_bootstrap" "bootstrap_rubrik" {
  cluster_name           = "${var.cluster_name}"
  admin_email            = "${var.admin_email}"
  admin_password         = "${var.admin_password}"
  management_gateway     = "${cidrhost(data.aws_subnet.default_gateway.cidr_block, 1)}"
  management_subnet_mask = "${cidrnetmask(data.aws_subnet.default_gateway.cidr_block)}"
  dns_search_domain      = "${var.dns_search_domain}"
  dns_name_servers       = "${var.dns_name_servers}"
  ntp_servers            = "${var.ntp_servers}"
  enable_encryption      = false

  node_config = "${zipmap(local.cluster_node_name, local.cluster_node_ips)}"
  timeout     = "${var.timeout}"
}
