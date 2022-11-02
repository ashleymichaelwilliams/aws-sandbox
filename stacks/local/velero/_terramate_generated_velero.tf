// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/velero/velero.tm.hcl

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
  name   = "ex-eks"
  region = "us-west-2"
}
module "velero" {
  app = {
    name          = "velero"
    version       = "2.32.1"
    chart         = "velero"
    force_update  = false
    wait          = true
    recreate_pods = true
    deploy        = false
    max_history   = 1
    image         = null
    tag           = null
  }
  app_deploy                  = true
  bucket                      = "velero-backups-ex-eks"
  cluster_name                = "ex-eks"
  count                       = 1
  namespace_deploy            = true
  openid_connect_provider_uri = replace(data.terraform_remote_state.eks.outputs.cluster_oidc_issuer_url, "https://", "")
  source                      = "terraform-module/velero/kubernetes"
  tags                        = {}
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
    ,
  ])
  version = "~> 1"
}
