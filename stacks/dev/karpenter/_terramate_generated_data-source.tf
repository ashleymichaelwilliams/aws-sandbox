// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/karpenter/karpenter.tm.hcl

data "terraform_remote_state" "eks" {
  backend = "remote"
  config = {
    organization = "adub-widgets"
    workspaces = {
      name = "aws-eks-dev"
    }
  }
  defaults = {
    cluster_id                         = "ex-eks"
    cluster_endpoint                   = "https://ABCDEFGHIJKLMNOPQRSTUVWXYZ.gr7.us-west-2.eks.amazonaws.com"
    cluster_certificate_authority_data = "dGhpcyBpcyB0ZXN0IGRhdGEuLi4K"
  }
}
