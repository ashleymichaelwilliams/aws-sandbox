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

      enable_ipv6 = false

      private_subnets = global.private_subnets
      private_subnet_tags = {
        tier                                               = "private"
        "kubernetes.io/cluster/${global.eks_cluster_name}" = "shared"
        "kubernetes.io/role/internal-elb"                  = 1

        # Tags subnets for Karpenter auto-discovery
        "karpenter.sh/discovery/${global.eks_cluster_name}" = global.eks_cluster_name
      }

      public_subnets = global.public_subnets #tfsec:ignore:aws-ec2-no-public-ip-subnet
      public_subnet_tags = {
        tier                                               = "public"
        "kubernetes.io/cluster/${global.eks_cluster_name}" = "shared"
        "kubernetes.io/role/elb"                           = 1
      }

      enable_nat_gateway   = true
      enable_dns_hostnames = true

      tags = global.tags
    }
  }
}