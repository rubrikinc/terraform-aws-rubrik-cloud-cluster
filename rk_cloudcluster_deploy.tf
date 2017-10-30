provider "aws" {
  version       = "~> 1.1"
  access_key    = "${var.aws_access_key}"
  secret_key    = "${var.aws_secret_key}"
  region        = "${var.aws_region}"
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${var.aws_vpc_id}"
}

resource "aws_instance" "rubrik_cluster" {
  count                   = "${4 * var.prod_environment}"
  instance_type           = "${var.aws_instance_type}"
  ami                     = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
  vpc_security_group_ids  = ["${var.aws_security_group_id}"]
  subnet_id               = "${element(data.aws_subnet_ids.subnets.ids, count.index)}"
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
  subnet_id               = "${element(data.aws_subnet_ids.subnets.ids, count.index)}"
}
