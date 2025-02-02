terraform {
  backend "s3" {
    bucket = "kube-9959"
    key    = "administrative/backend.tfstate"
    region = "us-east-1"
    dynamodb_table= "kube-tfstatelock-9959"
    
  }
}
 