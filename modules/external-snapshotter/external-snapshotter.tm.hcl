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
        oidc_provider_arn                  = "arn:aws:iam::1234567890:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0UVWXYZ"
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
        oidc_provider_arn                  = "arn:aws:iam::1234567890:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0UVWXYZ"
      }
    }
  }
}


# Generate '_terramate_generated_external-snapshotter.tf' in each stack
generate_hcl "_terramate_generated_external-snapshotter.tf" {
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

    provider "kubectl" {
      host                   = data.terraform_remote_state.eks.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.eks.outputs.cluster_certificate_authority_data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks.outputs.cluster_id]
      }
    }


    # 1-Install crds
    data "kubectl_file_documents" "crd" {
      content = file("crd.yaml")
    }

    resource "kubectl_manifest" "crd" {
      for_each  = data.kubectl_file_documents.crd.manifests
      yaml_body = each.value
    }


    # 2-Install csi-snapshotter
    data "kubectl_file_documents" "csi-snapshotter" {
      content = file("csi-snapshotter.yaml")
    }

    resource "kubectl_manifest" "csi-snapshotter" {
      for_each  = data.kubectl_file_documents.csi-snapshotter.manifests
      yaml_body = each.value

      depends_on = [
        kubectl_manifest.crd
      ]
    }


    # 3-Install snapshot-controller
    data "kubectl_file_documents" "snapshot-controller" {
      content = file("snapshot-controller.yaml")
    }

    resource "kubectl_manifest" "snapshot-controller" {
      for_each  = data.kubectl_file_documents.snapshot-controller.manifests
      yaml_body = each.value

      depends_on = [
        kubectl_manifest.crd
      ]
    }


    # 4-Configure NEW gp3 Storage Class
    data "kubectl_file_documents" "gp3-sc" {
      content = templatefile("gp3-sc.yaml.tftpl", {
        kms_key_id = [
          "${data.terraform_remote_state.eks.outputs.aws_kms_ebs_key_arn}"
        ]
      })
    }

    resource "kubectl_manifest" "gp3-sc" {
      for_each  = data.kubectl_file_documents.gp3-sc.manifests
      yaml_body = each.value

      depends_on = [
        kubectl_manifest.crd
      ]
    }

    # 5-Patch Existing GP2 StorageClass
    resource "kubernetes_annotations" "gp2" {
      api_version = "storage.k8s.io/v1"
      kind        = "StorageClass"

      metadata {
        name = "gp2"
      }

      annotations = {
        "storageclass.kubernetes.io/is-default-class" = ""
      }

      force = true

      depends_on = [
        kubectl_manifest.crd
      ]
    }


    # 6-Configure csi-aws-vsc VolumeSnapshotClass
    data "kubectl_file_documents" "csi-aws-vsc" {
      content = file("csi-aws-vsc.yaml")
    }

    resource "kubectl_manifest" "csi-aws-vsc" {
      for_each  = data.kubectl_file_documents.csi-aws-vsc.manifests
      yaml_body = each.value

      depends_on = [
        kubectl_manifest.crd
      ]
    }


    # 7-Configure ebs-csi-aws VolumeSnapshotClass
    data "kubectl_file_documents" "ebs-csi-aws" {
      content = file("ebs-csi-aws.yaml")
    }

    resource "kubectl_manifest" "ebs-csi-aws" {
      for_each  = data.kubectl_file_documents.ebs-csi-aws.manifests
      yaml_body = each.value

      depends_on = [
        kubectl_manifest.crd
      ]
    }

  }
}


# Generate 'crd.yaml' in each stack
generate_file "crd.yaml" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/v${global.external_snapshotter_version}/crd.yaml")
}

# Generate 'csi-snapshotter.yaml' in each stack
generate_file "csi-snapshotter.yaml" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/v${global.external_snapshotter_version}/csi-snapshotter.yaml")
}

# Generate 'snapshot-controller.yaml' in each stack
generate_file "snapshot-controller.yaml" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/v${global.external_snapshotter_version}/snapshot-controller.yaml")
}

# Generate 'gp3-sc.yaml' in each stack
generate_file "gp3-sc.yaml.tftpl" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/gp3-sc.yaml.tftpl")
}

# Generate 'csi-aws-vsc.yaml' in each stack
generate_file "csi-aws-vsc.yaml" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/csi-aws-vsc.yaml")
}

# Generate 'ebs-csi-aws.yaml' in each stack
generate_file "ebs-csi-aws.yaml" {
  content = tm_file("${terramate.root.path.fs.absolute}/modules/external-snapshotter/manifests/ebs-csi-aws.yaml")
}