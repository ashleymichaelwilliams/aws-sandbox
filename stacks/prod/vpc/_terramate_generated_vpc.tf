// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/vpc/vpc.tm.hcl

module "vpc" {
  azs = [
    "us-west-2a",
    "us-west-2b",
    "us-west-2c",
  ]
  cidr               = "10.1.0.0/16"
  create_vpc         = true
  enable_nat_gateway = true
  name               = "prod"
  private_subnet_tags = {
    tier = "private"
  }
  private_subnets = [
    "10.1.1.0/24",
    "10.1.2.0/24",
    "10.1.3.0/24",
  ]
  public_subnet_tags = {
    tier = "public"
  }
  public_subnets = [
    "10.1.11.0/24",
    "10.1.12.0/24",
    "10.1.13.0/24",
  ]
  source = "terraform-aws-modules/vpc/aws"
  tags = {
    env   = "prod"
    stack = "VPC - oregon-prod"
    team  = "netops"
  }
  version = "3.16.0"
}
