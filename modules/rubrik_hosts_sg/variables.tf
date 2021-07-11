variable "sg_id" {
  type = string
}

variable "create" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = { }
}

variable "rubrik_nodes_sg_id" {
  type = string
}