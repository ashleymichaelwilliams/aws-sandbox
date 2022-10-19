# Generate '_terramate_generated_metrics-server.tf' in each stack

generate_hcl "_terramate_generated_metrics-server.tf" {
  content {

    # data "terraform_remote_state" "eks" {
    #   backend = "local"

    #   config = {
    #     path = "../eks/${global.local_tfstate_path}"
    #   }
    # }


    # provider "kubernetes" {
    #   host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    #   cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

    #   exec {
    #     api_version = "client.authentication.k8s.io/v1beta1"
    #     command     = "aws"
    #     # This requires the awscli to be installed locally where Terraform is executed
    #     args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
    #   }
    # }


    # provider "helm" {
    #   kubernetes {
    #     host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
    #     cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

    #     exec {
    #       api_version = "client.authentication.k8s.io/v1beta1"
    #       command     = "aws"
    #       # This requires the awscli to be installed locally where Terraform is executed
    #       args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
    #     }
    #   }
    # }


    # locals {
    #   name = global.eks_cluster_name
    # }


    resource "helm_release" "metrics-server" {
      namespace        = local.namespace_name
      create_namespace = false

      wait = true

      name       = "metrics-server"
      repository = "https://kubernetes-sigs.github.io/metrics-server/"
      chart      = "metrics-server"
      version    = "3.8.2"

      # values = tolist([
      #   <<-YAML
      #   prometheus:
      #     server:
      #       global:
      #         external_labels:
      #           cluster_id: ${data.terraform_remote_state.eks.outputs.cluster_id}
      #     nodeExporter:
      #       enabled: false
      #   ingress:
      #     enabled: true
      #     annotations:
      #       kubernetes.io/ingress.class: alb
      #       alb.ingress.kubernetes.io/target-type: ip
      #       alb.ingress.kubernetes.io/scheme: internet-facing
      #       alb.ingress.kubernetes.io/backend-protocol: HTTP
      #       alb.ingress.kubernetes.io/healthcheck-path: /ui
      #       alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
      #     paths: ["/*"]
      #     pathType: ImplementationSpecific
      #     hosts:
      #       - cost-analyzer.local
      #   YAML
      # ])

      depends_on = [
        kubernetes_namespace.monitoring
      ]
    }

  }
}