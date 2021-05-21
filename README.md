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

| aws_region                                      | The region to deploy Rubrik Cloud Cluster nodes.                                                                         | string |                            |   yes    |

## Prerequisites

There are a few services you'll need in order to get this project off the ground:

- [Terraform](https://www.terraform.io/downloads.html) v0.15.4 or greater
- [Rubrik Provider for Terraform](https://github.com/rubrikinc/rubrik-provider-for-terraform) - provides Terraform functions for Rubrik
  - Only required to run the sample Rubrik Bootstrap command

## How You Can Help

We glady welcome contributions from the community. From updating the documentation to adding more functionality, all ideas are welcome. Thank you in advance for all of your issues, pull requests, and comments!

* [Contributing Guide](CONTRIBUTING.md)
* [Code of Conduct](CODE_OF_CONDUCT.md)

## License

* [MIT License](LICENSE)

## About Rubrik Build

We encourage all contributors to become members. We aim to grow an active, healthy community of contributors, reviewers, and code owners. Learn more in our [Welcome to the Rubrik Build Community](https://github.com/rubrikinc/welcome-to-rubrik-build) page.

We'd love to hear from you! Email us: build@rubrik.com
