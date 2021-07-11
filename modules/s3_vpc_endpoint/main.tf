data "aws_region" "current" {}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = var.vpc_id
  create             = var.create

  endpoints = {
    s3 = {
      # interface endpoint
      service = "s3"
      tags    = var.tags
      route_table_ids    = var.route_table_ids

    }
  }

  tags = merge(
    var.tags,
  )
}

data "aws_vpc_endpoint" "this" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  depends_on = [
    module.endpoints
  ]
}