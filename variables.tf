variable "aws_instance_type" {
  description = ""
  default     = "m5.xlarge"
}

variable "aws_vpc_security_group_ids" {
  description = ""
}

variable "aws_subnet_id" {
  description = ""
}

variable "aws_subnet_gateway" {
  description = ""
}

variable "aws_subnet_mask" {
  description = ""
}

####
variable "number_of_nodes" {
  description = ""
  default     = 4
}

variable "cluster_disk_size" {
  description = ""
  default     = "1024"
}

variable "cluster_name" {
  description = ""
  default     = "rubrik-cloud-cluster"
}

variable "admin_email" {
  description = ""
}

variable admin_password {
  description = ""
  default     = "RubrikGoForward"
}

variable "dns_search_domain" {
  description = ""
}

variable "dns_name_servers" {
  description = ""
}

variable "ntp_servers" {
  description = ""
  default     = ["8.8.8.8"]
}

variable "enable_encryption" {
  description = ""
}
