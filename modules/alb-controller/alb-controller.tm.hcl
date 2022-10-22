# Generate '_terramate_generated_data-source.tf' in each stack for Local File-System
generate_hcl "_terramate_generated_data-source.tf" {
  condition = global.isLocal == true

  content {

    data "terraform_remote_state" "eks" {
      backend = "local"

      config = {
        path = "../eks/${global.local_tfstate_path}"
      }
    }
  }
}


# Generate '_terramate_generated_data-source.tf' in each stack for Remote Terraform Cloud
generate_hcl "_terramate_generated_data-source.tf" {
  condition = global.isLocal == false

  content {
    data "terraform_remote_state" "eks" {
      backend = "remote"

      config = {
        organization = global.tfe_organization
        workspaces = {
          name = "aws-eks-${global.environment}"
        }
      }
    }
  }
}


# Generate '_terramate_generated_alb-controller.tf' in each stack
generate_hcl "_terramate_generated_alb-controller.tf" {
  content {

    provider "kubernetes" {
      host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
      }
    }


    provider "helm" {
      kubernetes {
        host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
        cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          # This requires the awscli to be installed locally where Terraform is executed
          args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
        }
      }
    }


    locals {
      name = global.eks_cluster_name
    }


    resource "kubernetes_service_account" "alb_control_service_account" {
      metadata {
        name      = "aws-load-balancer-controller"
        namespace = "kube-system"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
        }
        labels = {
          "app.kubernetes.io/component" = "controller"
          "app.kubernetes.io/name"      = "aws-load-balancer-controller"
        }
      }

      automount_service_account_token = true

    }


    module "alb_irsa" {
      source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      version = "~> 4.21.1"

      role_name = "alb-controller-${local.name}"

      attach_load_balancer_controller_policy = true

      oidc_providers = {
        main = {
          provider_arn               = data.terraform_remote_state.eks.outputs.oidc_provider_arn
          namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
        }
      }
    }

    resource "helm_release" "alb" {
      namespace        = "kube-system"
      create_namespace = false

      wait = true

      name       = "alb"
      repository = "https://aws.github.io/eks-charts"
      chart      = "aws-load-balancer-controller"
      version    = "1.4.5"

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


  }
}
