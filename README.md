# Rubrik Cloud Cluster Terraform Configuration

## Overview

This repository contains the Rubrik CloudCluster Terraform provisioning configuration. This can be used to provision and bootstrap a Cloud Cluster in Amazon Web Services either using spot instances (for lab based purposes), or standard instances (for persistent clusters).

Completing the steps detailed below will require that Terraform is installed and in your environment path,  that you are running the instance from a *nix shell (bash, zsh, etc), and that your machine is allowed HTTPS access through the AWS Security Group, and any Network ACLs, into the instances provisioned.

### Configuration Files

#### terraform.tfvars

The `terraform.tfvars` file is used to store parameterised variables for passing into the main payload. This is used in our Terraform configuration to store the following variables:


Variable | Description | Example Value
--- | --- | ---
aws_access_key | The AWS access key part of a keypair | ABCDEF0123456789ABCD
aws_secret_key | The AWS secret key part of a keypair | 134knasdcgkh12ip35ASCFGHJ1354/13245sASDF
aws_security_group_id | The security group to apply to the instances | sg-123456ab
aws_vpc_id | The VPC ID to provision into | vpc-123456ab
aws_subnet_id | The ID of the subnet to provision into | subnet-123456ab
aws_region* | The AWS region code (see here) | us-east-1
aws_instance_type* | The AWS instance type | m4.xlarge
aws_spot_price* | The spot price in dollars to bid for an instance (spot instance only) | 0.05
ntp_servers | The list of NTP servers to use | pool.ntp.org
dns_servers | The list of DNS servers to use | 8.8.8.8
admin_email_address | The email address to use for the admin account | administrator@demo.com
admin_password | The password to use when configuring the admin account | MySecretP@ss123!
cluster_name* | The name of the cluster - used to tag the created instances | my-rubrik-cluster
prod_environment* | If ‘true’ then normal on-demand instances will be used, if ‘false’ then spot instances are requested | true
cluster_size* | Used to determine the number of nodes to deploy in the cluster (default: 8) | 8

NOTE: those marked with an asterisk have a default value set in the ‘variables.tf’ file. These can be overridden using the ‘terraform.tfvars’ file if required.

NOTE: m4.xlarge is the only supported instance size for an AWS Cloud Cluster, and no smaller instance type should be used.

NOTE: tags cannot be applied to spot instances at provisioning, so ‘cluster_name’ is not used when ‘prod_environment’ is set to ‘false’.

NOTE: For DNS and NTP servers, where a list is provided rather than a single server (recommended), the list needs to be wrapped as follows: `"\"8.8.8.8\",\"8.8.4.4\""`. This ensures that it is correctly substituted when running the cluster bootstrap.

This file should be created and stored in the same folder as the rest of the Terraform configuration, the file should be formatted as shown below:

```none
aws_access_key = "ABCDEF0123456789ABCD"
aws_secret_key = "134knasdcgkh12ip35ASCFGHJ1354/13245sASDF"
aws_security_group_id   = "sg-abcdef12"
aws_vpc_id              = "vpc-abcdef12"
prod_environment        = false
dns_servers             = "8.8.8.8\",\"8.8.4.4"
ntp_servers             = "pool.ntp.org"
```

These variables can then be called as expected from the main Terraform configuration.

### # variables.tf

The `variables.tf` file declares reusable and default variables. This specifies the following defaults which can be overwritten in `terraform.tfvars` as shown above:

Variable | Description | Default Value
--- | --- | ---
aws_region | The AWS region code (see here) | us-east-1
instance_type | The AWS instance type | m4.xlarge
spot_price | The spot price in dollars to bid for an instance (spot instance only) | 0.05
cluster_name | The name of the cluster - used to tag the created instances | rubrik-test-cluster
prod_environment | If ‘true’ then normal on-demand instances will be used, if ‘false’ then spot instances are requested | true

Beyond these, it contains the AMI IDs for the Cloud Cluster image as follows:

```none
variable "rubrik_v4_0_3" {
 type = "map"
 default {
   us-east-2 = "ami-4582a020"
   # add other regions
 }
}

variable "rubrik_v4_0_2" {
 type = "map"
 default {
   us-east-2 = "ami-2c4c6f49"
   # add other regions
 }
}

variable "rubrik_v3_2_0" {
 type = "map"
 default {
   us-east-2 = "ami-4582a020"
   # add other regions
 }
}
```

As other regions are added, or minor version AMI IDs change (due to patches), this will need to be maintained with the correct IDs.

#### rk_cloudcluster_deploy.tf

This is the main configuration file for the Cloud Cluster, it contains the following sections:
Provider block - details the access settings for the AWS account

* Data block - gathers a list of subnets from the provided VPC ID, this lets us spread the cluster across the subnets
* Resource block - AWS Instance - builds instances for the nodes in the cluster (only used if ‘prod_environment’ is set to ‘true’)
* Resource block - AWS Spot Instance - builds spot instances for the nodes in the cluster (only used if ‘prod_environment’ is set to ‘false’)
* Template block - builds JSON payload for bootstrap of cluster
* Null resource block - calls the 'curl' command with the payload to bootstrap the cluster

The deployment will use v4.0.3 of the AMI as it stands; to change this modify this line in the fil:

```none
ami = "${var.rubrik_v4_0_3["${var.aws_region}"]}"
```

Replacing `var.rubrik_v4_0_3` with `var.rubrik_vx.y.z`, where `x.y.z` is in defined in the `variables.tf` file as shown above.

### Running the Terraform Configuration

#### Pre-requisites

##### Getting Terraform

Terraform can be downloaded and installed following instructions on the Terraform website; the configuration has been tested with v0.10.8.

##### Cloning the configuration from GitHub

The configuration can be cloned from the GitHub repository here, use the `git clone https://github.com/rubrik-devops/terraform-cloudcluster` command:

```none
tim@HAL:~$ git clone https://github.com/rubrik-devops/terraform-cloudcluster
Cloning into 'terraform-cloudcluster'...
Username for 'https://github.com': railroadmanuk
Password for 'https://railroadmanuk@github.com':
remote: Counting objects: 9, done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 9 (delta 2), reused 9 (delta 2), pack-reused 0
Unpacking objects: 100% (9/9), done.
Checking connectivity... done.
tim@HAL:~$
```

##### Initialising the directory

The directory can be initialised for Terraform use by running the `terraform init` command:

```none
tim@HAL:~/terraform-cloudcluster$ terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.1.0)...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
tim@HAL:~/terraform-cloudcluster$
```

##### Gaining access to the Rubrik Cloud Cluster AMI

Access to the Rubrik Cloud Cluster AMI will need to be granted by Rubrik Support; this can be requested via a normal support ticket.

##### Checking the directory contents

The directory contents should show as:

```none
tim@HAL:~$ tree
.
├── README.md
├── rk_cloudcluster_deploy.tf
├── terraform.tfvars
└── variables.tf

0 directories, 4 files
tim@HAL:~$
```

If any of these files are missing, follow the prerequisites section of the document again.

#### Requesting a Cloud Cluster

##### Planning

Run `terraform plan` to get information about what will happen when we apply the configuration; this will test that everything is set up correctly.

##### Applying

We can now apply the configuration to create the cluster using the `terraform apply` command.

##### Configuring the Cloud Cluster

The Cloud Cluster can now be configured through the Web UI; access to the interface will depend on the Security Group applied in the configuration above.

##### Destroying

Once the Cloud Cluster is no longer required, it can be destroyed using the `terraform destroy` command, and entering `yes` when prompted. This will also destroy the attached EBS volumes.