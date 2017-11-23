# Define the provider, and set the credentials and region
provider "aws" {
  version       = "~> 1.1"
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  region        = "${var.aws_region}"
}

# Create our production cluster
resource "aws_instance" "rubrik_cluster" {
  count                   = "${var.cluster_size}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_4["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${var.aws_subnet_id}"
  tags {
    Name = "${var.cluster_name}"
  }
}

# Gather data about the subnet we used, so we can generate the gateway and subnet mask
data "aws_subnet" "rubrik_cluster_subnet" {
  id = "${var.aws_subnet_id}"
}

# Determine the gateway and subnet mask for our subnet, using built in functions
locals {
  subnet_mask = "${cidrnetmask("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}")}"
  gateway_ip = "${cidrhost("${data.aws_subnet.rubrik_cluster_subnet.cidr_block}", 1)}"
}

# Generate our production host network config
data "template_file" "host_network" {
  count = "${var.cluster_size}"
  template = <<JSON
$${join(",",
  list(
    "$${jsonencode("netmask")}:$${jsonencode("${local.subnet_mask}")}",
    "$${jsonencode("gateway")}:$${jsonencode("${local.gateway_ip}")}",
    "$${jsonencode("address")}:$${jsonencode("${element(aws_instance.rubrik_cluster.*.private_ip, count.index)}")}",
  ))}"
JSON
}

data "template_file" "host_json" {
  count = "${var.cluster_size}"
  template = "$${jsonencode("${count.index}")}:{\"managementIpConfig\":{${element(data.template_file.host_network.*.rendered, count.index)}}}"
}

data "template_file" "all_host_json" {
  template = "{${join(",", data.template_file.host_json.*.rendered)}}"
}

# Build our production bootstrap JSON
data "template_file" "bootstrap_json" {
  template = "{\"dnsSearchDomains\":[],\"enableSoftwareEncryptionAtRest\":false,\"name\":\"${var.cluster_name}\",\"nodeConfigs\":${data.template_file.all_host_json.0.rendered},\"ntpServers\":[\"${var.ntp_servers}\"],\"dnsNameservers\":[\"${var.dns_servers}\"],\"adminUserInfo\":{\"password\":\"${var.admin_password}\",\"emailAddress\":\"${var.admin_email_address}\",\"id\":\"admin\"}}"
}

data "template_file" "bootstrap_json_normalised" {
  template = "${replace("${data.template_file.bootstrap_json.0.rendered}","\"\n","")}"
}

# Call the REST API on our production cluster to build the cluster. We wait 3 minutes for the API to be ready
resource "null_resource" "bootstrap" {
  provisioner "local-exec" {
    command = "sleep 180 && curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' -k -d '${data.template_file.bootstrap_json_normalised.rendered}' 'https://${aws_instance.rubrik_cluster.0.public_ip}/api/internal/cluster/me/bootstrap'"
  }
}
