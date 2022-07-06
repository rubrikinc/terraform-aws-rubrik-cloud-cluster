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
  policy = jsonencode ({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject*",
                "s3:GetObject*",
                "s3:ListMultipartUploadParts",
                "s3:PutObject*"
            ],
            "Resource": "${var.bucket.s3_bucket_arn}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucket*",
                "s3:ListBucket*"
        ],
            "Resource": "${var.bucket.s3_bucket_arn}"
        }
    ]
  })
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