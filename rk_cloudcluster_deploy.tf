# Define the provider, and set the credentials and region
provider "aws" {
  version       = "~> 1.1"
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  region        = "${var.aws_region}"
}

# Create our production cluster
resource "aws_instance" "rubrik_cluster" {
  count                   = "${4 * var.prod_environment}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${var.aws_subnet_id}"
  tags {
    Name = "${var.cluster_name}"
  }
}

# Create our spot instance cluster
resource "aws_spot_instance_request" "rubrik_cluster" {
  count                   = "${4 * (1 - var.prod_environment)}"
  spot_price              = "${var.aws_spot_price}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${var.aws_subnet_id}"
  wait_for_fulfillment    = true
}

# Gather data about the subnet we used, so we can generate the gateway and subnet mask
data "aws_subnet" "rubrik_cluster_subnet" {
  id = "${var.aws_subnet_id}"
}

# Build our production bootstrap JSON
data "template_file" "bootstrap_json" {
  template = "{\"dnsSearchDomains\":[],\"enableSoftwareEncryptionAtRest\":false,\"name\":\"${var.cluster_name}\",\"nodeConfigs\":{\"0\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance.rubrik_cluster.0.private_ip}\"}},\"1\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance.rubrik_cluster.1.private_ip}\"}},\"2\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance.rubrik_cluster.2.private_ip}\"}},\"3\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_instance.rubrik_cluster.3.private_ip}\"}}},\"ntpServers\":[\"${var.ntp_servers}\"],\"dnsNameservers\":[\"${var.dns_servers}\"],\"adminUserInfo\":{\"password\":\"${var.admin_password}\",\"emailAddress\":\"${var.admin_email_address}\",\"id\":\"admin\"}}"
  count = "${var.prod_environment}"
}

# Build our spot instance bootstrap json
data "template_file" "bootstrap_json_spot" {
  template = "{\"dnsSearchDomains\":[],\"enableSoftwareEncryptionAtRest\":false,\"name\":\"${var.cluster_name}\",\"nodeConfigs\":{\"0\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.0.private_ip}\"}},\"1\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.1.private_ip}\"}},\"2\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.2.private_ip}\"}},\"3\":{\"managementIpConfig\":{\"netmask\":\"${local.subnet_mask}\",\"gateway\":\"${local.gateway_ip}\",\"address\":\"${aws_spot_instance_request.rubrik_cluster.3.private_ip}\"}}},\"ntpServers\":[\"${var.ntp_servers}\"],\"dnsNameservers\":[\"${var.dns_servers}\"],\"adminUserInfo\":{\"password\":\"${var.admin_password}\",\"emailAddress\":\"${var.admin_email_address}\",\"id\":\"admin\"}}"
  count = "${1 - var.prod_environment}"
}

# Determine the gateway and subnet mask for our subnet, using built in functions
locals {
  subnet_mask = "${cidrnetmask("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}")}"
  gateway_ip = "${cidrhost("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}", 1)}"
}

# Call the REST API on our production cluster to build the cluster. We wait 3 minutes for the API to be ready
resource "null_resource" "bootstrap_spot" {
  provisioner "local-exec" {
    command = "sleep 180 && curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -k -d '${data.template_file.bootstrap_json_spot.rendered}' 'https://${aws_spot_instance_request.rubrik_cluster.0.public_ip}/api/internal/cluster/me/bootstrap'"
  }
  count = "${1 - var.prod_environment}"
}

# Call the REST API on our spot instance cluster to build the cluster. We wait 3 minutes for the API to be ready
resource "null_resource" "bootstrap_prod" {
  provisioner "local-exec" {
    command = "sleep 180 && curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -k -d '${data.template_file.bootstrap_json.rendered}' 'https://${aws_instance.rubrik_cluster.0.public_ip}/api/internal/cluster/me/bootstrap'"
  }
  count = "${var.prod_environment}"
}
