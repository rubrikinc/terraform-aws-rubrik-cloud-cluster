variable "create" {
  default = true
}

variable "vpc_id" {
  type = string
}

variable "route_table_ids" {
  type    = list(string)
  default = null
}

variable "tags" {
  type    = map(string)
  default = { Name = "s3-vpc-endpoint" }
}

variable "endpoint_name" {
  type = string
  default = null
}