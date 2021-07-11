variable "bucket" {
  type = string
}

variable "create" {
    type = bool
    default = true
}

variable "role_name" {
  type = string
}

variable "role_policy_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "tags" {
    type = map(string)
    default = {  }
}

data "template_file" "aws_iam_role_policy" {
  template = file("cc_es_policy.json.tpl")
  vars = {
    resource = var.bucket
  }
}

resource "aws_iam_role" "rubrik_ec2_s3" {
  count = var.create ? 1 : 0

  name = var.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "rubrik_ec2_s3_policy" {
  count  = var.create ? 1 : 0
  name   = var.role_policy_name
  role   = aws_iam_role.rubrik_ec2_s3[0].name
  policy = data.template_file.aws_iam_role_policy.rendered
}

resource "aws_iam_instance_profile" "rubrik_ec2_s3_profile" {
  count = var.create ? 1 : 0
  name  = var.instance_profile_name
  role  = aws_iam_role.rubrik_ec2_s3[0].name

  tags = var.tags
}

data "aws_iam_instance_profile" "rubrik_ec2_s3_profile" {
  name       = var.instance_profile_name
  depends_on = [aws_iam_instance_profile.rubrik_ec2_s3_profile]
}

output "aws_iam_instance_profile" {
    value = data.aws_iam_instance_profile.rubrik_ec2_s3_profile
}