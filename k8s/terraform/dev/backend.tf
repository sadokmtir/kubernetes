terraform {
  backend "s3" {
    bucket         = "kube-9886"
    key            = "k8s/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kube-tfstatelock-9886"
  }
}
