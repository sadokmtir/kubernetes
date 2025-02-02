variable "region" {
  default = "us-east-1"
}

variable "aws_bucket_prefix" {
  default = "kube"
}

variable "aws_dynamodb_table" {
  default = "kube-tfstatelock"
}

variable "full_access_users" {
  type    = list(string)
  default = []
}

variable "read_only_users" {
  type    = list(string)
  default = []
}

