variable "region" {
  default = "us-east-1"
}

variable "admin_account_role_name" {
  default = "super-admin-role"
}

variable "admin_account_id" {}
variable "dev_account_id" {}
variable "management_account_id" {}

variable "aws_bucket_prefix" {
  default = "kube"
}

variable "aws_dynamodb_table" {
  default = "kube-tfstatelock"
}

variable "project_name" {
  default = "kubernetes-cluster"
}
