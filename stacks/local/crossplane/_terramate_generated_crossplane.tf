// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/crossplane/crossplane.tm.hcl

provider "kubernetes" {
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
  host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.terraform_remote_state.eks.outputs.cluster_id,
    ]
    command = "aws"
  }
}
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)
    host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.terraform_remote_state.eks.outputs.cluster_id,
      ]
      command = "aws"
    }
  }
}
locals {
  name = "ex-eks"
}
resource "helm_release" "crossplane" {
  chart            = "crossplane"
  create_namespace = true
  name             = "crossplane"
  namespace        = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  version          = "1.10.0"
  wait             = true
}
