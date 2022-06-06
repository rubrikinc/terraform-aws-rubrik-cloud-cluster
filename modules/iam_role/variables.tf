variable "bucket" {
  type = string
}

variable "create" {
    type = bool
    default = true
}

variable "role_name" {
  type = string
}

variable "role_policy_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "tags" {
    type = map(string)
    default = {  }
}