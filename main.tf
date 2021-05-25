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

data "aws_ami_ids" "rubrik_cloud_cluster" {
  owners = ["679593333241"] 

  filter {
    name   = "name"
    values = ["rubrik-mp-cc-*"]
  }
}

##############################
# SSH KEY PAIR FOR INSTANCES #
##############################

resource "aws_key_pair" "rubrik_cloud_cluster" {
  key_name   = "${var.cluster_name}-key-pair"
  public_key = "${var.aws_public_key}"
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
  ami                    = "${element(data.aws_ami_ids.rubrik_cloud_cluster.ids, 0)}"
  vpc_security_group_ids = ["${aws_security_group.rubrik_cloud_cluster.id}"]
  subnet_id              = "${var.aws_subnet_id}"
  key_name               = "${aws_key_pair.rubrik_cloud_cluster.key_name}"

  tags = {
    Name = "${element(local.cluster_node_name, count.index)}"
  }

  disable_api_termination = "${var.aws_disable_api_termination}"

  root_block_device {
    encrypted = true
  }
  
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdc"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdd"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sde"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }

  ebs_block_device {
    device_name = "/dev/sdg"
    volume_type = "${var.cluster_disk_type}"
    volume_size = "${var.cluster_disk_size}"
    encrypted   = true
  }
}