// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/karpenter/karpenter.tm.hcl

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
locals {
  name = "ex-eks"
}
resource "kubernetes_manifest" "karpenter_node_template" {
  manifest = yamldecode(<<YAML
      apiVersion: karpenter.k8s.aws/v1alpha1
      kind: AWSNodeTemplate
      metadata:
        name: default
      spec:
        subnetSelector:
          karpenter.sh/discovery/${local.name}: ${local.name}
        securityGroupSelector:
          karpenter.sh/discovery/${local.name}: ${local.name}
        tags:
          karpenter.sh/discovery/${local.name}: ${local.name}
          CostCenter: "1234"
    YAML
  )
}
resource "kubernetes_manifest" "karpenter_provisioner" {
  depends_on = [
    kubernetes_manifest.karpenter_node_template,
  ]
  manifest = {
    apiVersion = "karpenter.sh/v1alpha5"
    kind       = "Provisioner"
    metadata = {
      name = "default"
    }
    spec = {
      limits = {
        resources = {
          cpu    = "32"
          memory = "64Gi"
        }
      }
      providerRef = {
        name = "default"
      }
      requirements = [
        {
          key      = "topology.kubernetes.io/zone"
          operator = "In"
          values = [
            "us-west-2a",
            "us-west-2b",
          ]
        },
        {
          key      = "karpenter.sh/capacity-type"
          operator = "In"
          values = [
            "on-demand",
            "spot",
          ]
        },
        {
          key      = "kubernetes.io/arch"
          operator = "In"
          values = [
            "amd64",
          ]
        },
        {
          key      = "node.kubernetes.io/instance-type"
          operator = "In"
          values = [
            "t2.medium",
            "t3.medium",
          ]
        },
      ]
      ttlSecondsAfterEmpty = 30
    }
  }
  field_manager {
    force_conflicts = true
    name            = "spec.requirements"
  }
}
resource "kubernetes_manifest" "karpenter_example_deployment" {
  depends_on = [
    kubernetes_manifest.karpenter_node_template,
    kubernetes_manifest.karpenter_provisioner,
  ]
  manifest = yamldecode(<<YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
      namespace: default
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.2
              resources:
                requests:
                  cpu: 1
    YAML
  )
  field_manager {
    force_conflicts = true
    name            = "spec.replicas"
  }
}
