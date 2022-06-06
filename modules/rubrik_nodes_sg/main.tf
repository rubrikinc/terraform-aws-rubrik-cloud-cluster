module "this" {
  source = "terraform-aws-modules/security-group/aws"

  create_sg         = false
  security_group_id = var.sg_id
  create = var.create

  ingress_with_self = [{ rule = "all-all" }]
  egress_rules      = ["all-all"]
  ingress_with_source_security_group_id = [
    { description              = "HTTPS over TCP"
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      source_security_group_id = var.rubrik_hosts_sg_id 
    },
    { description              = "SSH over TCP"
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = var.rubrik_hosts_sg_id 
    },
    { description              = "NFS over TCP"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      source_security_group_id = var.rubrik_hosts_sg_id 
    },
    { description              = "SMB over TCP"
      from_port                = 445
      to_port                  = 445
      protocol                 = "tcp"
      source_security_group_id = var.rubrik_hosts_sg_id
    },
    { description              = "SMB over TCP/UDP via NetBIOS"
      from_port                = 137
      to_port                  = 139
      protocol                 = -1
      source_security_group_id = var.rubrik_hosts_sg_id
    }
  ]
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Admin port for web service"
      cidr_blocks = var.cloud_cluster_nodes_admin_cidr 
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Admin port for ssh"
      cidr_blocks = var.cloud_cluster_nodes_admin_cidr 
    }
  ]

  tags = merge(
    var.tags,
    { "sg:purpose" = "rubrik-cluster-to-self" }
  )
}