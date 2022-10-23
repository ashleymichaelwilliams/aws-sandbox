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


# Generate '_terramate_generated_kubecost.tf' in each stack
generate_hcl "_terramate_generated_kubecost.tf" {
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


    resource "helm_release" "kubecost" {
      namespace        = "kubecost"
      create_namespace = true

      wait = true

      name       = "kubecost"
      repository = "https://kubecost.github.io/cost-analyzer/"
      chart      = "cost-analyzer"
      version    = "1.97.0"

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
      ])
    }

  }
}
