provider "aws" {
  version       = "~> 1.1"
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  region        = "${var.aws_region}"
}

resource "aws_instance_request" "rubrik_cluster" {
  count                   = "${4 * var.prod_environment}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${var.aws_subnet_id}"
  wait_for_fulfillment    = true
  tags {
    Name = "${var.cluster_name}"
  }
}

resource "aws_spot_instance_request" "rubrik_cluster" {
  count                   = "${4 * (1 - var.prod_environment)}"
  spot_price              = "${var.aws_spot_price}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${var.aws_subnet_id}"
  wait_for_fulfillment    = true
}

data "aws_subnet" "rubrik_cluster_subnet" {
  id = "${var.aws_subnet_id}"
}

locals {
  subnet_mask = "${cidrnetmask("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}")}"
  gateway_ip = "${cidrhost("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}", 1)}"
  bootstrap_json_spot = "{\"dnsSearchDomains\":[],\"enableSoftwareEncryptionAtRest\":false,\"name\":\"${var.cluster_name}\",\"nodeConfigs\":{\"0\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.0.private_ip}\"}},\"1\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.1.private_ip}\"}},\"2\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.2.private_ip}\"}},\"3\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.3.private_ip}\"}}},\"ntpServers\":[\"pool.ntp.org\"],\"dnsNameservers\":[\"8.8.8.8\"],\"adminUserInfo\":{\"password\":\"${var.admin_password}\",\"emailAddress\":\"${var.admin_email_address}\",\"id\":\"admin\"}}"
}

resource "null_resource" "bootstrap_spot_instance" {
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "sleep 180 && curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -k -d '${local.bootstrap_json_spot}' 'https://${aws_spot_instance_request.rubrik_cluster.0.public_ip}/api/internal/cluster/me/bootstrap'"
  }
  count = "${1 - var.prod_environment}"
}
/*
resource "null_resource" "bootstrap_spot_prod" {
  locals {
    bootstrap_json = "{\"dnsSearchDomains\":[],\"enableSoftwareEncryptionAtRest\":false,\"name\":\"${var.cluster_name}\",\"nodeConfigs\":{\"0\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance_request.rubrik_cluster.0.private_ip}\"}},\"1\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance_request.rubrik_cluster.1.private_ip}\"}},\"2\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance_request.rubrik_cluster.2.private_ip}\"}},\"3\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance_request.rubrik_cluster.3.private_ip}\"}}},\"ntpServers\":[\"pool.ntp.org\"],\"dnsNameservers\":[\"8.8.8.8\"],\"adminUserInfo\":{\"password\":\"${var.admin_password}\",\"emailAddress\":\"${var.admin_email_address}\",\"id\":\"admin\"}}"
  }
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    command = "sleep 180 && curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -k -d '${local.bootstrap_json}' 'https://${aws_instance_request.rubrik_cluster.0.public_ip}/api/internal/cluster/me/bootstrap'"
  }
  count = "${var.prod_environment}"
}
*/