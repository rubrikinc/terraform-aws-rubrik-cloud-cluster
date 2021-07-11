{
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
            "Resource": "arn:aws:s3:::${resource}/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucket*",
                "s3:ListBucket*"
        ],
            "Resource": "arn:aws:s3:::${resource}"
        }
    ]
}

