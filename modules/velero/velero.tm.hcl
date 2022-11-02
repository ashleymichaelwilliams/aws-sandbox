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


# Generate '_terramate_generated_velero.tf' in each stack
generate_hcl "_terramate_generated_velero.tf" {
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
      name   = global.eks_cluster_name
      region = global.region
    }


    module "velero" {
      source  = "terraform-module/velero/kubernetes"
      version = "~> 1"

      count = 1

      namespace_deploy            = true
      app_deploy                  = true
      cluster_name                = global.eks_cluster_name
      openid_connect_provider_uri = replace(data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url, "https://", "")
      
      bucket                      = "velero-backups-ex-eks"
      app = {
        name          = global.helm_chart_velero.releaseName
        version       = global.helm_chart_velero.version
        chart         = "velero"
        force_update  = false
        wait          = true
        recreate_pods = true
        deploy        = false
        max_history   = 1
        image         = null
        tag           = null
      }
      tags = {}

      values = tolist([
        <<-EOF
        initContainers:
          - name: velero-plugin-for-aws
            image: velero/velero-plugin-for-aws:v1.4.1
            imagePullPolicy: IfNotPresent
            volumeMounts:
              - mountPath: /target
                name: plugins
        installCRDs: true
        securityContext:
          fsGroup: 1337
        configuration:
          provider: aws
          backupStorageLocation:
            name: default
            provider: aws
            bucket: "velero-backups-${local.name}"
            prefix: "velero/sandbox/velero-backups-${local.name}"
            config:
              region: ${local.region}
          volumeSnapshotLocation:
            name: default
            provider: aws
            config:
              region: ${local.region}
          backupSyncPeriod:
          resticTimeout:
          restoreResourcePriorities:
          restoreOnlyMode:
          extraEnvVars:
            AWS_CLUSTER_NAME: ${local.name}
          logLevel: info
        rbac:
          create: true
          clusterAdministrator: true
        credentials:
          useSecret: false
        backupsEnabled: true
        snapshotsEnabled: true
        deployRestic: true
        EOF
      ])
    }


  }
}
