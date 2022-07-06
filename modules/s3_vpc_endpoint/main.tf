locals {
  get_endpoint_data = var.create == true ? 1 : 0
}
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3_endpoint" {
  count             = local.get_endpoint_data
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  vpc_endpoint_type = "Gateway"

  tags = var.tags
}

data "aws_vpc_endpoint" "this" {
  count        = local.get_endpoint_data
  vpc_id       = var.vpc_id
  id           = aws_vpc_endpoint.s3_endpoint[0].id
  depends_on = [
    aws_vpc_endpoint.s3_endpoint
  ]
}