module "this" {
  source = "terraform-aws-modules/security-group/aws"

  create_sg         = false
  security_group_id = var.sg_id
  create = var.create

  ingress_with_source_security_group_id = [
    {
      from_port = 12800
      to_port = 12801
      protocol = "tcp"
      description              = "Ports for Rubrik Backup Service (RBS)"
      source_security_group_id = var.rubrik_nodes_sg_id
    },
  ]

  tags = merge(
    var.tags,
    { "sg:purpose" = "rubrik-cluster-to-self" }
  )
}