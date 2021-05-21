variable "aws_region" {
  description = "The region to deploy Rubrik Cloud Cluster nodes."
}
variable "aws_instance_type" {
  description = "The type of instance to use as Rubrik Cloud Cluster nodes."
  default     = "m5.4xlarge"
}

variable "aws_disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = true
}

variable "aws_vpc_security_group_name_cloud_cluster_nodes" {
  description = "The name of the security group to create for Rubrik Cloud Cluster to use."
  default     = "Rubrik Cloud Cluster"
}

variable "aws_vpc_security_group_name_cloud_cluster_hosts" {
  description = "The name of the security group to create for Rubrik Cloud Cluster to communicate with EC2 instances."
  default     = "Rubrik Cloud Cluster Hosts"
}

variable "aws_subnet_id" {
variable "aws_public_key" {
  description = "The public key material needed to create an AWS key pair for use with Rubrik Cloud Cluster."
  sensitive   = true
}

variable "number_of_nodes" {
  description = "The total number of nodes in the Cloud Cluster."
  default     = 4
}

variable "cluster_disk_type" {
  description = "The disk type to use for Rubrik Cloud Cluster data disks (sc1 or st1). NOTE: st1 disks require six 8TB disks."
  default     = "st1"
}

variable "cluster_disk_size" {
  description = "The size of each the three data disks in each node."
  default     = "1024"
}

variable "cluster_name" {
  description = "Unique name to assign to the Rubrik cluster. This will also be used to populate the EC2 instance name tag. For example, rubrik-cloud-cluster-1, rubrik-cloud-cluster-2 etc."
  default     = "rubrik-cloud-cluster"
}

variable "admin_email" {
  description = "The Rubrik cluster sends messages for the admin account to this email address."
}

variable admin_password {
  description = "Password for the Cloud Cluster admin account."
  default     = "RubrikGoForward"
}

variable "dns_search_domain" {
  type        = list
  description = "List of search domains that the DNS Service will use to resolve hostnames that are not fully qualified."
}

variable "dns_name_servers" {
  type        = list
  description = "List of the IPv4 addresses of the DNS servers."
}

variable "ntp_servers" {
  description = "List of FQDN or IPv4 addresses of a network time protocol (NTP) server(s)"
  default     = ["169.254.169.123"]
}

variable "timeout" {
  description = "The number of seconds to wait to establish a connection the Rubrik cluster before returning a timeout error."
  default     = 15
}
