variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "k8s-cluster-dev"
}

variable "dev_account_id" {}

variable "control_nodes_type" {
  type    = string
  default = "t3.large"
}
variable "control_nodes_count" {
  type    = number
  default = 2
}
