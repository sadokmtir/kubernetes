terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "admin"
      Owner       = "terraform"
      Project     = var.project_name
    }
  }
}


