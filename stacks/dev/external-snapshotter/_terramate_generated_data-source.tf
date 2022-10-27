// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/external-snapshotter/external-snapshotter.tm.hcl

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
    oidc_provider_arn                  = "arn:aws:iam::1234567890:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0UVWXYZ"
  }
}
