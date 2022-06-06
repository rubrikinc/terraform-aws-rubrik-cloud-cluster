# Terraform Module - AWS Cloud Cluster Deployment

![AWS CodeBuild Status](https://codebuild.us-west-2.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiNzBMVFNxcThTQTlCVlVQN3IxRmNnbHRZZjFaaDdxR2dDWXV3SkY2M3hhZTh5WHVGbzhuVklQZzRQNkppZ1paVlREejFrUmFWV0U4VEduR2N5TzQ1YW04PSIsIml2UGFyYW1ldGVyU3BlYyI6IkZrd3VMRTV0a3c0MXdpY1ciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=master)

Terraform module which deploys a new Rubrik Cloud Cluster in AWS.

## Documentation

Here are some resources to get you started! If you find any challenges from this project are not properly documented or are unclear, please [raise an issue](https://github.com/rubrikinc/terraform-aws-rubrik-cloud-cluster/issues/new/choose) and let us know! This is a fun, safe environment - don't worry if you're a GitHub newbie!

- [Terraform Module Registry](https://registry.terraform.io/modules/rubrikinc/rubrik-cloud-cluster)
- [Quick Start Guide](https://github.com/rubrikinc/terraform-aws-rubrik-cloud-cluster/blob/master/docs/quick-start.md)

### Usage

```hcl
module "rubrik_aws_cloud_cluster" {
  source  = "rubrikinc/rubrik-cloud-cluster/aws"

  aws_region                 = "us-west-1"
  aws_ami_filter             = ["rubrik-mp-cc-7*"]
  cluster_name               = "rubrik-cloud-cluster"
  admin_email                = "build@rubrik.com"
  dns_search_domain          = ["rubrikdemo.com"]
  dns_name_servers           = ["10.142.9.3"]
}
```

### Inputs

The following are the variables accepted by the module.

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| aws_region                                      | The region to deploy Rubrik Cloud Cluster nodes.                                                                         | string |                            |   yes    |
| aws_ami_filter                                  | Cloud Cluster AWS AMI name pattern(s) to search for. Use [\"rubrik-mp-cc-<X>*\"]. Where <X> is the major version of CDM. |  list  |                            |   yes    |
| aws_image_id                                    | AWS Image ID to deploy. Set to 'latest' or leave blank to deploy the latest version as determined by `aws_ami_filter`.   | string |           latest           |    no    |
| create_key_pair                                 | If true, a new AWS SSH Key-Pair will be created using the aws_key_pair_name and aws_public_key settings.                 |  bool  |            true            |    no    |
| aws_key_pair_name                               | Name for the AWS SSH Key-Pair being created or the existing AWS SSH Key-Pair being used.                                 | string |                            |    no    |
*Note: The `aws_ami_filter` and `aws_ami_owners` variables are only used when the `aws_image_id` variable is blank or set to `latest`*
| cloud_cluster_nodes_admin_cidr                  | The CIDR range for the systems used to administer the Cloud Cluster via SSH and HTTPS.                                   | string |         0.0.0.0/0          |    no    |
| create_cloud_cluster_hosts_sg                   | If true, creates a new Security Group for node to host traffic from the Rubrik cluster.                                  | string |            true            |    no    |
| aws_subnet_id                                   | The VPC Subnet ID to launch Rubrik Cloud Cluster in.                                                                     | string |                            |   yes    |
| aws_public_key                                  | he public key material needed to create an AWS key pair for use with Rubrik Cloud Cluster.                               | string |                            |   yes    |
| number_of_nodes                                 | The total number of nodes in Rubrik Cloud Cluster.                                                                       |  int   |             4              |    no    |
| cluster_disk_type                               | The disk type to use for Rubrik Cloud Cluster data disks (sc1 or st1). NOTE: st1 disks require six 8TB disks.            | string |            st1             |   yes    |
| cluster_disk_count                               | The number of disks to use per node. Set to zero to leverage S3 object storage if deploying Cloud Cluster ES                               | number |            4            |    no    |
| cluster_name                                    | Unique name to assign to Rubrik Cloud Cluster. Also used for EC2 instance name tag. For example, rubrik-1, rubrik-2 etc. | string |                            |   yes    |
| admin_email                                     | The Rubrik Cloud Cluster sends messages for the admin account to this email address.                                     | string |                            |   yes    |
| admin_password                                  | Password for the Rubrik Cloud Cluster admin account.                                                                     | string |      RubrikGoForward       |    no    |
| dns_search_domain                               | List of search domains that the DNS Service will use to resolve hostnames that are not fully qualified.                  |  list  |                            |   yes    |
| dns_name_servers                                | List of the IPv4 addresses of the DNS servers.                                                                           |  list  |                            |   yes    |
| ntp_servers                                     | List of FQDN or IPv4 addresses of a network time protocol (NTP) server(s)                                                |  list  |        ["8.8.8.8"]         |    no    |
| timeout                                         | The number of seconds to wait to establish a connection the Rubrik cluster before returning a timeout error.             |  int   |             15             |    no    |

## Prerequisites

There are a few services you'll need in order to get this project off the ground:

- [Terraform](https://www.terraform.io/downloads.html) v0.15.4 or greater
- [Rubrik Provider for Terraform](https://github.com/rubrikinc/rubrik-provider-for-terraform) - provides Terraform functions for Rubrik
  - Only required to run the sample Rubrik Bootstrap command

## How You Can Help

We glady welcome contributions from the community. From updating the documentation to adding more functionality, all ideas are welcome. Thank you in advance for all of your issues, pull requests, and comments!

- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)

## License

- [MIT License](LICENSE)

## About Rubrik Build

We encourage all contributors to become members. We aim to grow an active, healthy community of contributors, reviewers, and code owners. Learn more in our [Welcome to the Rubrik Build Community](https://github.com/rubrikinc/welcome-to-rubrik-build) page.

We'd love to hear from you! Email us: build@rubrik.com
