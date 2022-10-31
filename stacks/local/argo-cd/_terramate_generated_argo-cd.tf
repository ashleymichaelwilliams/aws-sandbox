// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/argo-cd/argo-cd.tm.hcl

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
resource "helm_release" "argo-cd" {
  chart            = "argo-cd"
  create_namespace = true
  name             = "argo-cd"
  namespace        = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  values = tolist([
    <<-YAML
        redis-ha:
          enabled: true

        controller:
          replicas: 1

        server:
          autoscaling:
            enabled: true
            minReplicas: 2

        repoServer:
          autoscaling:
            enabled: true
            minReplicas: 2

        applicationSet:
          replicaCount: 2
        YAML
    ,
  ])
  version = "5.12.1"
  wait    = true
}
