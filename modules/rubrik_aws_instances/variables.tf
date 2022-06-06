variable "node_names" {
  type = set(string)
}

variable "node_config" {
  type = object({
    instance_type = string
    ami_id  = string
    sg_ids = set(string)
    subnet_id = string
    key_pair_name = string
    disable_api_termination = bool
    iam_instance_profile = string
    availability_zone = string
    tags = map(string)
  })
}

variable "disks" {
  type = map(any)
}