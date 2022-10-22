// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/alb-controller/alb-controller.tm.hcl

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "adub-widgets"
    workspaces = {
      name = "aws-eks-dev"
    }
  }
}
