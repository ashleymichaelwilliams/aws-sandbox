// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/eks/eks.tm.hcl

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
  defaults = {
    vpc_id = "vpc-123456789"
    private_subnets = [
      "subnet-123456789",
    ]
  }
}
