# all the AWS details
variable "aws_access_key"         {}
variable "aws_secret_key"         {}
variable "aws_security_group_id"  {}
variable "aws_vpc_id"             {}
variable "aws_subnet_id"          {}
variable "aws_region"             { default = "us-east-2" }
variable "aws_instance_type"      { default = "m4.xlarge" } # this should not be changed unless absolutely required
variable "aws_spot_price"         { default = "0.05" } # only used if 'prod_environment' is false
# set our DNS and NTP servers
variable "ntp_servers"            {}
variable "dns_servers"            {}
# set the details of the admin account
variable "admin_email_address"    {}
variable "admin_password"         {}
# determine the cluster name
variable "cluster_name"           { default = "rubrik-test-cluster" }
# set whether this is production (on-demand instances), or non-prod (spot instances)
variable "prod_environment"       { default = true }
variable "cluster_size"           { default = 8 }

variable "rubrik_v4_0_4" {
  type = "map"
  default {
    us-east-1 = "ami-f39e2189"
    us-east-2 = "ami-3dd4fb58"
    # add other regions
  }
}

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