# Generate '_terramate_generated_data-source.tf' in each stack for Local File-System
generate_hcl "_terramate_generated_data-source.tf" {
  condition = global.isLocal == true

  content {

    data "terraform_remote_state" "eks" {
      backend = "local"

      config = {
        path = "../eks/${global.local_tfstate_path}"
      }

      defaults = {
        cluster_id                         = "ex-eks"
        cluster_endpoint                   = "https://ABCDEFGHIJKLMNOPQRSTUVWXYZ.gr7.us-west-2.eks.amazonaws.com"
        cluster_certificate_authority_data = "dGhpcyBpcyB0ZXN0IGRhdGEuLi4K"
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

      defaults = {
        cluster_id                         = "ex-eks"
        cluster_endpoint                   = "https://ABCDEFGHIJKLMNOPQRSTUVWXYZ.gr7.us-west-2.eks.amazonaws.com"
        cluster_certificate_authority_data = "dGhpcyBpcyB0ZXN0IGRhdGEuLi4K"
      }
    }
  }
}


# Generate '_terramate_generated_monitoring.tf' in each stack
generate_hcl "_terramate_generated_monitoring.tf" {
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
      name           = global.eks_cluster_name
      namespace_name = "monitoring"
    }


    resource "kubernetes_namespace" "monitoring" {
      metadata {
        name = local.namespace_name
      }
    }

  }
}
