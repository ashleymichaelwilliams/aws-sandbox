// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/external-snapshotter/external-snapshotter.tm.hcl

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
provider "kubectl" {
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
data "kubectl_file_documents" "crd" {
  content = file("crd.yaml")
}
resource "kubectl_manifest" "crd" {
  for_each  = data.kubectl_file_documents.crd.manifests
  yaml_body = each.value
}
data "kubectl_file_documents" "csi-snapshotter" {
  content = file("csi-snapshotter.yaml")
}
resource "kubectl_manifest" "csi-snapshotter" {
  depends_on = [
    kubectl_manifest.crd,
  ]
  for_each  = data.kubectl_file_documents.csi-snapshotter.manifests
  yaml_body = each.value
}
data "kubectl_file_documents" "snapshot-controller" {
  content = file("snapshot-controller.yaml")
}
resource "kubectl_manifest" "snapshot-controller" {
  depends_on = [
    kubectl_manifest.crd,
  ]
  for_each  = data.kubectl_file_documents.snapshot-controller.manifests
  yaml_body = each.value
}
data "kubectl_file_documents" "gp3-sc" {
  content = templatefile("gp3-sc.yaml.tftpl", {
    kms_key_id = [
      "${data.terraform_remote_state.eks.outputs.aws_kms_ebs_key_arn}",
    ]
  })
}
resource "kubectl_manifest" "gp3-sc" {
  depends_on = [
    kubectl_manifest.crd,
  ]
  for_each  = data.kubectl_file_documents.gp3-sc.manifests
  yaml_body = each.value
}
resource "kubernetes_annotations" "gp2" {
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = ""
  }
  api_version = "storage.k8s.io/v1"
  depends_on = [
    kubectl_manifest.crd,
  ]
  force = true
  kind  = "StorageClass"
  metadata {
    name = "gp2"
  }
}
data "kubectl_file_documents" "csi-aws-vsc" {
  content = file("csi-aws-vsc.yaml")
}
resource "kubectl_manifest" "csi-aws-vsc" {
  depends_on = [
    kubectl_manifest.crd,
  ]
  for_each  = data.kubectl_file_documents.csi-aws-vsc.manifests
  yaml_body = each.value
}
data "kubectl_file_documents" "ebs-csi-aws" {
  content = file("ebs-csi-aws.yaml")
}
resource "kubectl_manifest" "ebs-csi-aws" {
  depends_on = [
    kubectl_manifest.crd,
  ]
  for_each  = data.kubectl_file_documents.ebs-csi-aws.manifests
  yaml_body = each.value
}
