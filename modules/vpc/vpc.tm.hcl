
# globals {
# }

##############################################################################
# Generate '_terramate_generated_vpc.tf' in each stack

generate_hcl "_terramate_generated_vpc.tf" {
  content {

    module "vpc" {
      source = "terraform-aws-modules/vpc/aws?ref=3.16.0"

      cidr            = global.vpc_cidr_block
      create_vpc      = true
      private_subnets = global.private_subnets
    }
  }
}