variable "aws_region" {
  description = "The region to deploy Rubrik Cloud Cluster nodes."
}

variable "aws_instance_type" {
  description = "The type of instance to use as Rubrik Cloud Cluster nodes."
  default     = "m5.4xlarge"
}

variable "aws_disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection on the Rubrik Cloud Cluster nodes."
  default     = true
}

variable "aws_vpc_cloud_cluster_nodes_sg_name" {
  description = "The name of the security group to create for Rubrik Cloud Cluster to use."
  default     = "Rubrik Cloud Cluster"
}

variable "aws_vpc_cloud_cluster_hosts_sg_name" {
  description = "The name of the security group to create for Rubrik Cloud Cluster to communicate with EC2 instances."
  default     = "Rubrik Cloud Cluster Hosts"
}

variable "aws_cloud_cluster_nodes_sg_ids" {
  description = "Extra security groups to add to Rubrik cluster nodes"
  type        = list(string)
  default     = []
}

variable "aws_iam_instance_profile" {
  description = "IAM instance profile for accessing S3 with Cloud Cluster ES"
  type        = string
  default     = ""
}

variable "aws_tags" {
  description = "Extra tags to add to Rubrik cluster nodes"
  type        = map(string)
  default     = {}
}

variable "aws_subnet_id" {
  description = "The VPC Subnet ID to launch Rubrik Cloud Cluster in."
}

variable "aws_public_key" {
  description = "The public key material needed to create an AWS key pair for use with Rubrik Cloud Cluster."
  sensitive   = true
}

variable "number_of_nodes" {
  description = "The total number of nodes in Rubrik Cloud Cluster."
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

variable "cluster_disk_count" {
  description = "The number of disks for each node in the cluster. Set to 1 to use with S3 storage for Cloud Cluster ES"
  type        = number
  default     = 4
}

variable "cluster_name" {
  description = "Unique name to assign to the Rubrik Cloud Cluster. This will also be used to populate the EC2 instance name tag. For example, rubrik-cloud-cluster-1, rubrik-cloud-cluster-2 etc."
  default     = "rubrik-cloud-cluster"
}

variable "admin_email" {
  description = "The Rubrik Cloud Cluster sends messages for the admin account to this email address."
}

variable "admin_password" {
  description = "Password for the Rubrik Cloud Cluster admin account."
  default     = "RubrikGoForward"
}

variable "dns_search_domain" {
  type        = list(any)
  description = "List of search domains that the DNS Service will use to resolve hostnames that are not fully qualified."
  default     = []
}

variable "dns_name_servers" {
  type        = list(any)
  description = "List of the IPv4 addresses of the DNS servers."
  default     = ["169.254.169.253"]
}

variable "ntp_servers" {
  description = "List of FQDN or IPv4 addresses of a network time protocol (NTP) server(s)"
  default     = ["169.254.169.123"]
}

variable "timeout" {
  description = "The number of seconds to wait to establish a connection the Rubrik cluster before returning a timeout error."
  default     = 15
}

variable "aws_ami_owners" {
  description = "Set of AWS Account that own the Rubrik Cloud Cluster AMI"
  type        = set(string)
  default     = ["679593333241"]
}

variable "aws_ami_filter" {
  description = "Set of AWS AMI names to search for"
  type        = set(string)
  default     = ["rubrik-mp-cc-*"]
}

variable "environment_tag" {
  description = "Prefix used to identify an environment for tagging like \"prod\" or \"europe:shared:dev\""
  type        = string
  default     = ""
}

variable "environment" {
  description = "Prefix used to identify an environment for to be added to names like \"prod\" or \"europe-shared-dev\""
  type        = string
  default     = ""
}

variable "aws_key_pair_name" {
  description = "Name used to identify a new or existing AWS SSH Key-Pair"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Should a new AWS SSH Key-Pair be created?"
  type        = bool
  default     = true
}

variable "create_aws_rubrik_nodes_sg" {
  description = "Should a new Security Group be created for node to node traffic within the Rubrik cluster?"
  type        = bool
  default     = true
}

variable "create_aws_rubrik_hosts_sg" {
  description = "Should a new Security Group be created for node to host traffic from the Rubrik cluster?"
  type        = bool
  default     = true
}

variable "create_iam_role" {
  description = "Should the required IAM role, role policy, and instance profile be created?"
  type        = bool
  default     = true
}

variable "create_s3_vpc_endpoint" {
  description = "Should the required VPC Endpoint and S3 Endpoint Service for Cloud Cluster ES be created?"
  type        = bool
  default     = false
}

variable "create_s3_bucket" {
  description = "Should the required S3 bucket for Cloud Cluster ES be created?"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Optional name to assign the S3 bucket"
  type        = string
  default     = ""
}

variable "aws_cloud_cluster_iam_role_name" {
  description = "Optional name to assign to the AWS IAM Role that is used to access S3"
  type        = string
  default     = ""
}

variable "aws_cloud_cluster_iam_role_policy_name" {
  description = "Optional name to assign to the AWS IAM Role policy that is used to access S3"
  type        = string
  default     = ""
}

variable "aws_cloud_cluster_ec2_instance_profile_name" {
  description = "Optional name to assign to the AWS EC2 Instance Profile that links the IAM Role to the cluster"
  type        = string
  default     = ""
}

