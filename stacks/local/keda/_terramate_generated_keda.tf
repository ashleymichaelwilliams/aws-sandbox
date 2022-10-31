// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/keda/keda.tm.hcl

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
resource "helm_release" "keda" {
  chart            = "keda"
  create_namespace = true
  name             = "keda"
  namespace        = "keda"
  repository       = "https://kedacore.github.io/charts"
  version          = "2.8.2"
  wait             = true
}
