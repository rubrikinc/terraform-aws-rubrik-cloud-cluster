# Quick Start: Rubrik AWS Cloud Cluster Deployment Terraform Module

Completing the steps detailed below will require that Terraform is installed and in your environment path, that you are running the instance from a \*nix shell (bash, zsh, etc), and that your machine is allowed HTTPS access through the AWS Security Group, and any Network ACLs, into the instances provisioned.

## Configuration

In your [Terraform configuration](https://learn.hashicorp.com/terraform/getting-started/build#configuration) (`main.tf`) populate the following and update the variables to your specific environment:

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

You may also add additional variables, such as `ntp_servers`, to overwrite the default values.

## Inputs

The following are the variables accepted by the module.

### Instance/Node Settings

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| aws_region                                      | The region to deploy Rubrik Cloud Cluster nodes.                                                                         | string |                            |   yes    |
| aws_instance_type                               | The type of instance to use as Rubrik Cloud Cluster nodes. CC-ES requires m5.4xlarge.                                    | string |         m5.4xlarge         |    no    |
| aws_disable_api_termination                     | If true, enables EC2 Instance Termination Protection on the Rubrik Cloud Cluster nodes.                                  |  bool  |            true            |    no    |
| aws_tags                                        | Tags to add to the resources that this Terraform script creates, including the Rubrik cluster nodes.                     |  map   |                            |    no    |
| number_of_nodes                                 | The total number of nodes in Rubrik Cloud Cluster.                                                                       |  int   |             3              |    no    |
| aws_ami_owners                                  | AWS marketplace account(s) that owns the Rubrik Cloud Cluster AMIs.                                                      |  list  |      ["679593333241"]      |    no    |
| aws_ami_filter                                  | Cloud Cluster AWS AMI name pattern(s) to search for. Use [\"rubrik-mp-cc-<X>*\"]. Where <X> is the major version of CDM. |  list  |                            |   yes    |
| aws_image_id                                    | AWS Image ID to deploy. Set to 'latest' or leave blank to deploy the latest version as determined by `aws_ami_filter`.   | string |           latest           |    no    |
| create_key_pair                                 | If true, a new AWS SSH Key-Pair will be created using the aws_key_pair_name and aws_public_key settings.                 |  bool  |            true            |    no    |
| aws_key_pair_name                               | Name for the AWS SSH Key-Pair being created or the existing AWS SSH Key-Pair being used.                                 | string |                            |    no    |
| aws_public_key                                  | The public key material needed to create an AWS Key-Pair for use with Rubrik Cloud Cluster.                              | string |                            |    no    |
| private-key-file                                | If a new AWS SSH Key-Pair is generated, the name of the file to save the private key material in.                        | string |  ./.terraform/cc-key.pem   |    no    |

*Note: When using the `aws_tags` variable, the "Name" tag is automatically used by this TF for those resources that support it.*

*Note: The `aws_ami_filter` and `aws_ami_owners` variables are only used when the `aws_image_id` variable is blank or set to `latest`*

*Note: When using the `aws_image_id` variable, see [Selecting a specific image](#selecting-a-specific-image) for details on finding images.*

*Note: When using the `aws_key_pair_name` variable, if a new AWS SSH Key-Pair is being created and no name is specified, a name will be automatically generated.*

*Note: When using the `aws_public_key` variable, if a new AWS SSH Key-Pair is being created and no material is provided, new key material will be auto generated.*

<br>

### Network Settings

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| create_cloud_cluster_nodes_sg                   | If true, creates a new Security Group for node to node traffic within the Rubrik cluster.                                |  bool  |            true            |    no    |
| aws_vpc_cloud_cluster_nodes_sg_name             | The name of the security group to create for Rubrik Cloud Cluster to use.                                                | string |    Rubrik Cloud Cluster    |    no    |
| cloud_cluster_nodes_admin_cidr                  | The CIDR range for the systems used to administer the Cloud Cluster via SSH and HTTPS.                                   | string |         0.0.0.0/0          |    no    |
| create_cloud_cluster_hosts_sg                   | If true, creates a new Security Group for node to host traffic from the Rubrik cluster.                                  | string |            true            |    no    |
| aws_vpc_cloud_cluster_hosts_sg_name             | The name of the security group to create for Rubrik Cloud Cluster to communicate with EC2 instances.                     | string | Rubrik Cloud Cluster Hosts |    no    |
| aws_cloud_cluster_nodes_sg_ids                  | Additional security groups to add to Rubrik cluster nodes.                                                               | string |                            |    no    |
| aws_subnet_id                                   | The VPC Subnet ID to launch Rubrik Cloud Cluster in.                                                                     | string |                            |   yes    |

### Storage Settings

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| cluster_disk_type                               | Disk type for the data disks (st1, sc1 or gp2). Use gp2 for CC-ES. Use sc1 for 48TB CC nodes. Use st1 for all others.    | string |            gp2             |    no    |
| cluster_disk_size                               | The size (in GB) of each data disk on each node. Cloud Cluster ES only requires 1 512 GB disk per node.                  | string |            512             |    no    |
| cluster_disk_count                              | The number of disks for each node in the cluster. Set to 1 to use with S3 storage for Cloud Cluster ES.                  |  int   |             1              |    no    |

### Cloud Cluster ES Settings

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| create_iam_role                                 | If true, create required IAM role, role policy, and instance profile needed for Cloud Cluster ES.                        |  bool  |           true             |    no    |
| aws_cloud_cluster_iam_role_name                 | AWS IAM Role name for Cloud Cluster ES. If blank a name will be auto generated. Required if create_iam_role is false.    | string |                            |    no    |
| aws_cloud_cluster_iam_role_policy_name          | AWS IAM Role policy name for Cloud Cluster ES if create_iam_role is true. If blank a name will be auto generated.        | string |                            |    no    |
| aws_cloud_cluster_ec2_instance_profile_name     | AWS EC2 Instance Profile name that links the IAM Role to Cloud Cluster ES. If blank a name will be auto generated.       | string |                            |    no    |
| create_s3_bucket                                | If true, create am S3 bucket for Cloud Cluster ES data storage.                                                          |  bool  |           true             |    no    |
| s3_bucket_name                                  | Name of the S3 bucket to use with Cloud Cluster ES data storage. If blank a name will be auto generated.                 | string |                            |    no    |
| create_s3_vpc_endpoint                          | If true, create a VPC Endpoint and S3 Endpoint Service for Cloud Cluster ES.                                             |  bool  |           true             |    no    |

### Bootstrap Settings

| Name                                            | Description                                                                                                              |  Type  |          Default           | Required |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | :----: | :------------------------: | :------: |
| cluster_name                                    | Unique name to assign to Rubrik Cloud Cluster. Also used for EC2 instance name tag. For example, rubrik-1, rubrik-2 etc. | string |                            |   yes    |
| admin_email                                     | The Rubrik Cloud Cluster sends messages for the admin account to this email address.                                     | string |                            |   yes    |
| admin_password                                  | Password for the Rubrik Cloud Cluster admin account.                                                                     | string |      RubrikGoForward       |    no    |
| dns_search_domain                               | List of search domains that the DNS Service will use to resolve hostnames that are not fully qualified.                  |  list  |                            |   yes    |
| dns_name_servers                                | List of the IPv4 addresses of the DNS servers.                                                                           |  list  |    ["169.254.169.253"]     |    no    |
| ntp_servers                                     | List of FQDN or IPv4 addresses of a network time protocol (NTP) server(s)                                                |  list  |    ["169.254.169.123"]     |    no    |
| timeout                                         | The number of seconds to wait to establish a connection the Rubrik cluster before returning a timeout error.             |  int   |             15             |    no    |

## Running the Terraform Configuration

This section outlines what is required to run the configuration defined above.

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v0.15.4 or greater
- [Rubrik Provider for Terraform](https://github.com/rubrikinc/rubrik-provider-for-terraform) - provides Terraform functions for Rubrik
  - Only required to run the sample Rubrik Bootstrap command

### Initialize the Directory

The directory can be initialized for Terraform use by running the `terraform init` command:

```none
Initializing modules...
- module.rubrik_aws_cloud_cluster
  Getting source "rubrikinc/aws-rubrik-cloud-cluster/module"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (2.2.0)...
- Downloading plugin for provider "null" (2.1.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.2"
* provider.null: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Gain Access to the Rubrik Cloud Cluster AMI

The Terraform script will automatically install the latest maintenance release of Rubrik Cloud Cluster major version (as defined by the `aws_ami_filter` variable) from the AWS Marketplace. If a different version of Cloud Cluster is required modify the filters in the `aws_image_id`, `aws_ami_owners` and/or `aws_ami_filter` variables.

### Planning

Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that everything is set up correctly.

### Applying

We can now apply the configuration to create the cluster using the `terraform apply` command.

### Configuring the Cloud Cluster

If the example script for bootstrapping the Rubrik Cloud Cluster is not used, bootstrap the Rubrik Cloud Cluster as documented in the Rubrik Cloud Cluster guide.
The Cloud Cluster can now be configured through the Web UI; access to the interface will depend on the Security Group applied in the configuration above.

### Destroying

Once the Cloud Cluster is no longer required, it can be destroyed using the `terraform destroy` command, and entering `yes` when prompted. This will also destroy the attached EBS volumes.

## Selecting a specific image

To select a specific image to deploy replace the `aws_image_id` variable with the AMI ID of the Rubrik Marketplace Image to deploy. To find a list of the Rubrik Cloud Cluster images that are available in a specific region run the following `aws` cli command (requires that the AWS CLI be installed):

```none
  aws ec2 describe-images \
    --filters 'Name=owner-id,Values=679593333241' 'Name=name,Values=rubrik-mp-cc-<X>*' \
     --query 'sort_by(Images, &CreationDate)[*].{"Create Date":CreationDate, "Image ID":ImageId, Version:Description}' \
    --region '<region>' \
    --output table
```

Where <X> is the major version of Rubrik CDM (ex. `rubrik-mp-cc-7*`)

Example: 

```none
aws ec2 describe-images \
     --filters 'Name=owner-id,Values=679593333241' 'Name=name,Values=rubrik-mp-cc-7*' \
     --query 'sort_by(Images, &CreationDate)[*].{"Create Date":CreationDate, "Image ID":ImageId, Version:Description}' \
      --region 'us-west-2' \
     --output table

------------------------------------------------------------------------------------------
|                                     DescribeImages                                     |
+--------------------------+-------------------------+-----------------------------------+
|        Create Date       |        Image ID         |              Version              |
+--------------------------+-------------------------+-----------------------------------+
|  2022-02-04T21:49:48.000Z|  ami-0056ddcc69df6fb5c  |  Rubrik OS rubrik-7-0-0-14764     |
|  2022-04-01T00:13:58.000Z|  ami-026233b876a279622  |  Rubrik OS rubrik-7-0-1-15183     |
|  2022-04-12T04:50:31.000Z|  ami-03d68b150241012ec  |  Rubrik OS rubrik-7-0-1-p1-15197  |
|  2022-04-27T05:56:27.000Z|  ami-09a3baba1545aa5f7  |  Rubrik OS rubrik-7-0-1-p2-15336  |
|  2022-05-13T21:51:54.000Z|  ami-0af1ff3ee7517fefa  |  Rubrik OS rubrik-7-0-1-p3-15425  |
|  2022-05-20T00:01:55.000Z|  ami-0cc1db55e45f3109b  |  Rubrik OS rubrik-7-0-1-p4-15453  |
|  2022-05-26T19:08:31.000Z|  ami-04d6af7c6f6629ce1  |  Rubrik OS rubrik-7-0-2-15510     |
+--------------------------+-------------------------+-----------------------------------+
```

