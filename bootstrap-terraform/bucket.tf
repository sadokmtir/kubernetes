resource "aws_s3_bucket" "state_bucket" {
  bucket = local.bucket_name
  tags = {
    Name = local.bucket_name
  }

}

resource "aws_s3_bucket_ownership_controls" "state_bucket_ownership_controls" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "state_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.state_bucket_ownership_controls]

  bucket = aws_s3_bucket.state_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_group" "state_bucket_full_access_group" {
  name = "${local.bucket_name}-full-access"
}

resource "aws_iam_group" "state_bucket_read_only_group" {
  name = "${local.bucket_name}-read-only"
}

resource "aws_iam_group_membership" "full_access_membership" {
  name  = "${local.bucket_name}-full-access"
  users = var.full_access_users
  group = aws_iam_group.state_bucket_full_access_group.name
}

resource "aws_iam_group_membership" "read_only_membership" {
  name  = "${local.bucket_name}-read-only"
  users = var.read_only_users
  group = aws_iam_group.state_bucket_read_only_group.name
}


resource "aws_iam_group_policy" "full_access_policy" {
  name  = "${local.bucket_name}-full-access-policy"
  group = aws_iam_group.state_bucket_full_access_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          "${aws_dynamodb_table.terraform_statelock.arn}"
        ]
      }
    ]
  })
}

resource "aws_iam_group_policy" "read_only_policy" {
  name  = "${local.bucket_name}-read-only-policy"
  group = aws_iam_group.state_bucket_read_only_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ]
      },
    ]
  })
}

output "state_bucket" {
  value = aws_s3_bucket.state_bucket.bucket
}

output "dynamodb_statelock" {
  value = aws_dynamodb_table.terraform_statelock.name
}
