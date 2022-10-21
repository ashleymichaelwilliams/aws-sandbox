// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/kubecost/kubecost.tm.hcl

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
resource "helm_release" "kubecost" {
  chart            = "cost-analyzer"
  create_namespace = true
  name             = "kubecost"
  namespace        = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer/"
  values = tolist([
    <<-YAML
        prometheus:
          server:
            global:
              external_labels:
                cluster_id: ${data.terraform_remote_state.eks.outputs.cluster_id}
          nodeExporter:
            enabled: false
        ingress:
          enabled: true
          annotations:
            kubernetes.io/ingress.class: alb
            alb.ingress.kubernetes.io/target-type: ip
            alb.ingress.kubernetes.io/scheme: internet-facing
            alb.ingress.kubernetes.io/backend-protocol: HTTP
            alb.ingress.kubernetes.io/healthcheck-path: /ui
            alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
          paths: ["/*"]
          pathType: ImplementationSpecific
          hosts:
            - cost-analyzer.local
        YAML
    ,
  ])
  version = "1.97.0"
  wait    = true
}
