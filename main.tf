resource "null_resource" "create_cluster_node_name" {
  count = "${var.number_of_nodes}"

  triggers {
    node_number = "${count.index + 1}"
  }
}

locals {
  cluster_node_name = "${formatlist("${var.cluster_name}-%s", null_resource.create_cluster_node_name.*.triggers.node_number)}"

  cluster_node_ips = "${aws_instance.rubrik_cluster.*.private_ip}"
}

data "aws_ami" "rubrik_cloud_cluster" {
  most_recent = true

  owners = ["447546863256"] # Rubrik

  filter {
    name   = "name"
    values = ["rubrik-*"]
  }
}

resource "aws_instance" "rubrik_cluster" {
  count                  = "${var.number_of_nodes}"
  instance_type          = "${var.aws_instance_type}"
  ami                    = "${data.aws_ami.rubrik_cloud_cluster.id}"
  vpc_security_group_ids = "${var.aws_vpc_security_group_ids}"
  subnet_id              = "${var.subnet_id}"

  tags {
    Name = "${element(local.cluster_node_name, count.index)}"
  }

  disable_api_termination = false

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

provider "rubrik" {
  node_ip  = "${aws_instance.rubrik_cluster.0.private_ip}"
  username = ""
  password = ""
}

resource "rubrik_bootstrap" "bootstrap_rubrik" {
  cluster_name           = "${var.cluster_name}"
  admin_email            = "${var.admin_email}"
  admin_password         = "${var.admin_password}"
  management_gateway     = "${var.aws_subnet_gateway}"
  management_subnet_mask = "${var.aws_subnet_mask}"
  dns_search_domain      = "${var.dns_search_domain}"
  dns_name_servers       = "${var.dns_name_servers}"
  ntp_servers            = "${var.ntp_servers}"
  enable_encryption      = "${var.enable_encryption}"

  node_config = "${zipmap(local.cluster_node_name, local.cluster_node_ips)}"
}
