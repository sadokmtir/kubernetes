resource "random_integer" "bucket_suffix" {
  min = 1000
  max = 9999
}

locals {
  bucket_name         = "${var.aws_bucket_prefix}-${random_integer.bucket_suffix.result}"
  dynamodb_table_name = "${var.aws_dynamodb_table}-${random_integer.bucket_suffix.result}"
}


resource "aws_dynamodb_table" "terraform_statelock" {
  name           = local.dynamodb_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
