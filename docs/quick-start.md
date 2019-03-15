# Quick Start: Rubrik AWS Cloud Cluster Deployment Terraform Module

Completing the steps detailed below will require that Terraform is installed and in your environment path, that you are running the instance from a *nix shell (bash, zsh, etc), and that your machine is allowed HTTPS access through the AWS Security Group, and any Network ACLs, into the instances provisioned.



## Configuration

In your [Terraform configuration](https://learn.hashicorp.com/terraform/getting-started/build#configuration) (`main.tf`) populate the following and update the variables to your specific environment:

```hcl
module "rubrik_aws_cloud_cluster" {
  source = "github.com/rubrikinc/use-case-terraform-deploy-cloudcluster-aws"

  aws_vpc_security_group_ids = ["sg-0fc82928bd323ed3qq"]
  aws_subnet_id              = "subnet-0278a40b29e52203a"
  cluster_name               = "rubrik-cloud-cluster"
  admin_email                = "build@rubrik.com"
  dns_search_domain          = ["rubrikdemo.com"]
  dns_name_servers           = ["10.142.9.3"]
}
```

You may also add additional variables, such as `ntp_servers`, to overwrite the default values.

## Inputs

The following are the variables accepted by the module.

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


## Running the Terraform Configuration

This section outlines what is required to run the configuration defined above. 

### Prerequisites

* [Terraform](https://www.terraform.io/downloads.html) v0.10.3 or greater
* [Rubrik Provider for Terraform](https://github.com/rubrikinc/rubrik-provider-for-terraform) - provides Terraform functions for Rubrik


### Initialize the Directory

The directory can be initialized for Terraform use by running the `terraform init` command:

```none
Initializing modules...
- module.rubrik_aws_cloud_cluster
  Getting source "github.com/rubrikinc/use-case-terraform-deploy-cloudcluster-aws"

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

Access to the Rubrik Cloud Cluster AMI will need to be granted by Rubrik Support; this can be requested via a normal support ticket.

### Planning

Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that everything is set up correctly.

### Applying

We can now apply the configuration to create the cluster using the `terraform apply` command.

### Configuring the Cloud Cluster

The Cloud Cluster can now be configured through the Web UI; access to the interface will depend on the Security Group applied in the configuration above.

### Destroying

Once the Cloud Cluster is no longer required, it can be destroyed using the `terraform destroy` command, and entering `yes` when prompted. This will also destroy the attached EBS volumes.
