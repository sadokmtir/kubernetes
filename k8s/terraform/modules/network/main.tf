data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name               = "kubernetes-iac-vpc"
  cidr               = "10.240.0.0/16"
  azs                = [data.aws_availability_zones.available.names[0]]
  private_subnets    = ["10.240.1.0/24"]
  public_subnets     = ["10.240.100.0/24"]
  enable_nat_gateway = "true"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.public_subnets[0]
}
