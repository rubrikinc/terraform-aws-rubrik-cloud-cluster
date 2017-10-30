variable "aws_access_key"         {}
variable "aws_secret_key"         {}
variable "aws_security_group_id"  {}
variable "aws_vpc_id"             {}
variable "aws_region"             { default = "us-east-2" }
variable "aws_instance_type"      { default = "m4.xlarge" }
variable "aws_spot_price"         { default = "0.05" }
variable "cluster_name"           { default = "rubrik-test-cluster" }
variable "prod_environment"       { default = true }

variable "rubrik_v4_0_3" {
  type = "map"
  default {
    us-east-2 = "ami-4582a020"
    # add other regions
  }
}

variable "rubrik_v4_0_2" {
  type = "map"
  default {
    us-east-2 = "ami-2c4c6f49"
    # add other regions
  }
}

variable "rubrik_v3_2_0" {
  type = "map"
  default {
    us-east-2 = "ami-4582a020"
    # add other regions
  }
}