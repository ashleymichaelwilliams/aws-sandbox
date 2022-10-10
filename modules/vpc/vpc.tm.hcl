# Generate '_terramate_generated_vpc.tf' in each stack

generate_hcl "_terramate_generated_vpc.tf" {
  content {

    module "vpc" {
      source  = "terraform-aws-modules/vpc/aws"
      version = "3.16.0"

      name       = global.name
      create_vpc = true

      cidr = global.vpc_cidr_block
      azs  = global.azs

      private_subnets = global.private_subnets
      private_subnet_tags = {
        tier = "private"
      }

      public_subnets = global.public_subnets
      public_subnet_tags = {
        tier = "public"
      }

      enable_nat_gateway = true

      tags = global.tags
    }
  }
}