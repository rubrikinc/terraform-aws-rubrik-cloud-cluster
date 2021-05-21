# Quick Start: Rubrik AWS Cloud Cluster Deployment Terraform Module

Completing the steps detailed below will require that Terraform is installed and in your environment path, that you are running the instance from a *nix shell (bash, zsh, etc), and that your machine is allowed HTTPS access through the AWS Security Group, and any Network ACLs, into the instances provisioned.

## Configuration

In your [Terraform configuration](https://learn.hashicorp.com/terraform/getting-started/build#configuration) (`main.tf`) populate the following and update the variables to your specific environment:

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

You may also add additional variables, such as `ntp_servers`, to overwrite the default values.

## Inputs

The following are the variables accepted by the module.

| aws_region                                      | The region to deploy Rubrik Cloud Cluster nodes.                                                                         | string |                            |   yes    |

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

Access to the Rubrik Cloud Cluster AMI will need to be granted by Rubrik Support; this can be requested via a normal support ticket.

### Planning

Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that everything is set up correctly.

### Applying

We can now apply the configuration to create the cluster using the `terraform apply` command.

### Configuring the Cloud Cluster

The Cloud Cluster can now be configured through the Web UI; access to the interface will depend on the Security Group applied in the configuration above.

### Destroying

Once the Cloud Cluster is no longer required, it can be destroyed using the `terraform destroy` command, and entering `yes` when prompted. This will also destroy the attached EBS volumes.
