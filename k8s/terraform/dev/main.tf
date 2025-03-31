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

  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Environment = "dev"
      Owner       = "terraform"
      Project     = var.project_name
    }
  }
}

module "network" {
  source = "../modules/network"
}

module "compute" {
  source             = "../modules/compute"
  node_instance_type = var.control_nodes_type
  control_node_count = var.control_nodes_count
  node_vpc_id        = module.network.vpc_id
  node_subnet_id     = module.network.subnet_id
  use_spot_instances = true
}
