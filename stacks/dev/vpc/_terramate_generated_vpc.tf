// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/vpc/vpc.tm.hcl

module "vpc" {
  cidr       = "10.0.0.0/16"
  create_vpc = true
  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
  ]
  source = "terraform-aws-modules/vpc/aws?ref=3.16.0"
}
