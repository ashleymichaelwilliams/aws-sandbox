// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/alb-controller/alb-controller.tm.hcl

data "terraform_remote_state" "eks" {
  backend = "local"
  config = {
    path = "../eks/terraform.tfstate"
  }
}
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
resource "kubernetes_service_account" "alb_control_service_account" {
  automount_service_account_token = true
  metadata {
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
    }
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
    }
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
  }
}
module "alb_irsa" {
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    main = {
      provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller",
      ]
    }
  }
  role_name = "alb-controller-${local.name}"
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 4.21.1"
}
resource "helm_release" "alb" {
  chart            = "aws-load-balancer-controller"
  create_namespace = false
  name             = "alb"
  namespace        = "kube-system"
  repository       = "https://aws.github.io/eks-charts"
  version          = "1.4.5"
  wait             = true
  set {
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_id
  }
  set {
    name  = "serviceAccount.create"
    value = false
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
