# Terraform Module - AWS Cloud Cluster Deployment

![AWS CodeBuild Status](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiNzBMVFNxcThTQTlCVlVQN3IxRmNnbHRZZjFaaDdxR2dDWXV3SkY2M3hhZTh5WHVGbzhuVklQZzRQNkppZ1paVlREejFrUmFWV0U4VEduR2N5TzQ1YW04PSIsIml2UGFyYW1ldGVyU3BlYyI6IkZrd3VMRTV0a3c0MXdpY1ciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)


Terraform module which deploys a new Rubrik Cloud Cluster in AWS.

## Documentation

Here are some resources to get you started! If you find any challenges from this project are not properly documented or are unclear, please [raise an issue](https://github.com/rubrikinc/terraform-aws-rubrik-cloud-cluster/issues/new/choose) and let us know! This is a fun, safe environment - don't worry if you're a GitHub newbie!

* [Terraform Module Registry](https://registry.terraform.io/modules/rubrikinc/rubrik-cloud-cluster)
* [Quick Start Guide](https://github.com/rubrikinc/terraform-aws-rubrik-cloud-cluster/blob/master/docs/quick-start.md)

### Usage

```hcl
module "rubrik_aws_cloud_cluster" {
  source  = "rubrikinc/rubrik-cloud-cluster/aws"

  aws_vpc_security_group_ids = ["sg-0fc82928bd323ed3qq"]
  aws_subnet_id              = "subnet-0278a40b29e52203a"
  cluster_name               = "rubrik-cloud-cluster"
  admin_email                = "build@rubrik.com"
  dns_search_domain          = ["rubrikdemo.com"]
  dns_name_servers           = ["10.142.9.3"]
}
```

### Inputs

| Name                        | Description                                                                                                            |  Type  |     Default     | Required |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------|:------:|:---------------:|:--------:|
| aws_instance_type           | The type of instance to use as the Cloud Cluster nodes.                                                                | string |    m5.xlarge    |    no    |
| aws_disable_api_termination | If true, enables EC2 Instance Termination Protection                                                                   |  bool  |       true      |    no    |
| aws_vpc_security_group_ids  | A list of security group IDs to associate with the Cloud Cluster.                                                      |  list  |                 |    yes   |
| aws_subnet_id               | The VPC Subnet ID to launch the Cloud Cluster in.                                                                      | string |                 |    yes   |
| number_of_nodes             | The total number of nodes in the Cloud Cluster                                                                         |   int  |        4        |    no    |
| cluster_disk_size           | The size of each the three data disks in each node.                                                                    | string |       1024      |    no    |
| cluster_name                | Unique name to assign to the Rubrik cluster. Also used for EC2 instance name tag. For example, rubrik-1, rubrik-2 etc. | string |                 |    yes   |
| admin_email                 | The Rubrik cluster sends messages for the admin account to this email address.                                         | string |                 |    yes   |
| admin_password              | Password for the Cloud Cluster admin account.                                                                          | string | RubrikGoForward |    no    |
| dns_search_domain           | List of search domains that the DNS Service will use to resolve hostnames that are not fully qualified.                |  list  |                 |    yes   |
| dns_name_servers            | List of the IPv4 addresses of the DNS servers.                                                                         |  list  |                 |    yes   |
| ntp_servers                 | List of FQDN or IPv4 addresses of a network time protocol (NTP) server(s)                                              |  list  |   ["8.8.8.8"]   |          |
| timeout                     | The number of seconds to wait to establish a connection the Rubrik cluster before returning a timeout error.           |   int  |        15       |    no    |


## Prerequisites

There are a few services you'll need in order to get this project off the ground:

* [Terraform](https://www.terraform.io/downloads.html) v0.10.3 or greater
* [Rubrik Provider for Terraform](https://github.com/rubrikinc/rubrik-provider-for-terraform) - provides Terraform functions for Rubrik

## How You Can Help

We glady welcome contributions from the community. From updating the documentation to adding more functionality, all ideas are welcome. Thank you in advance for all of your issues, pull requests, and comments!

* [Contributing Guide](CONTRIBUTING.md)
* [Code of Conduct](CODE_OF_CONDUCT.md)

## License

* [MIT License](LICENSE)

## About Rubrik Build

We encourage all contributors to become members. We aim to grow an active, healthy community of contributors, reviewers, and code owners. Learn more in our [Welcome to the Rubrik Build Community](https://github.com/rubrikinc/welcome-to-rubrik-build) page.

We'd love to hear from you! Email us: build@rubrik.com
