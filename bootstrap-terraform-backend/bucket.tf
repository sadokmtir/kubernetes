resource "aws_s3_bucket" "state_bucket" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }

}

resource "aws_s3_bucket_policy" "state_bucket_policy" {
  bucket = aws_s3_bucket.state_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.state_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.state_bucket.id}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.admin_account_id}:root",
          ] # TODO: Add terraform role later
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.state_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.state_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_ownership_controls" "state_bucket_ownership_controls" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "read_only_role" {
  name = "ReadOnlyAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = ["arn:aws:iam::${var.dev_account_id}:root"]
        }
      }
    ]
  })
}

resource "aws_iam_policy" "read_only_policy" {
  name        = "ReadOnlyPolicy"
  description = "Provides read-only access to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:Get*", "s3:List*"], # Read-only S3 actions
        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "read_only_attachment" {
  role       = aws_iam_role.read_only_role.name
  policy_arn = aws_iam_policy.read_only_policy.arn
}

#This should go to the other accounts (dev, prod, etc)
# resource "aws_iam_policy" "assume_read_only_role_policy" {
#   name        = "AssumeReadOnlyRolePolicy"
#   description = "Allows IAM users to assume the ReadOnlyAccess role"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = "sts:AssumeRole",
#         Resource = aws_iam_role.read_only_role.arn
#       }
#     ]
#   })
# }
# resource "aws_iam_group" "read_only_group" {
#   name = "read-only-group-tf-state"

# }

# resource "aws_iam_group_policy_attachment" "allow_assume_read_only_role" {
#   group      = aws_iam_group.read_only_group.name
#   policy_arn = aws_iam_policy.assume_read_only_role_policy.arn
# }


output "state_bucket" {
  value = aws_s3_bucket.state_bucket.bucket
}

output "dynamodb_statelock" {
  value = aws_dynamodb_table.terraform_statelock.name
}
