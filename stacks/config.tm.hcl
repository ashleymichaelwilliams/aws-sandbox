globals {
  local_tfstate_path = "terraform.tfstate"

  terraform_version = "~> 1.2.9"

  terraform_aws_provider_region      = global.region
  terraform_aws_provider_version     = "~> 4.34"
  terraform_k8s_provider_version     = "2.14.0"
  terraform_helm_provider_version    = "2.7.0"
  terraform_kubectl_provider_version = ">= 1.7.0"

  # Leave this and configure override at the environment level
  isLocal = true # Global default unless specified lower in the stack as an override

  # Terraform Cloud Configuration
  tfe_organization = "adub-widgets"
  tfe_workspace    = "${terramate.stack.id}"
  # Usage: dynamically generate string which is the remote state "workspace" name of the 'current' stack/state.
  # Example Result: aws-eks-dev


  # EKS Managed Node Group
  mng_config = {
    spot = {

      name = "spot-eks-mng"

      capacity_type  = "SPOT"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 5
      desired_size = 2

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      # block_device_mappings = {
      #   xvda = {
      #     ebs = {
      #       volume_size           = 50
      #       volume_type           = "gp3"
      #       iops                  = 150
      #       throughput            = 150
      #     }
      #   }
      # }

    }
  }

  # Global Configuration of Helm Charts
  helm_chart_alb-controller = {
    version     = "1.4.5"
    releaseName = "alb"
    namespace   = "kube-system"
  }


  helm_chart_argo-cd = {
    version     = "5.12.1"
    releaseName = "argo-cd"
    namespace   = "argo-cd"
  }

  helm_chart_crossplane = {
    version     = "1.10.0"
    releaseName = "crossplane"
    namespace   = "crossplane"
  }

  helm_chart_flagger = {
    version     = "1.24.1"
    releaseName = "flagger"
    namespace   = "flagger"
  }

  helm_chart_karpenter = {
    version     = "v0.18.0"
    releaseName = "karpenter"
    namespace   = "karpenter"
  }

  helm_chart_keda = {
    version     = "2.8.2"
    releaseName = "keda"
    namespace   = "keda"
  }

  helm_chart_kubecost = {
    version     = "1.97.0"
    releaseName = "kubecost"
    namespace   = "kubecost"
  }

  helm_chart_metrics-server = {
    version     = "3.8.2"
    releaseName = "metrics-server"
    namespace   = "monitoring"
  }

  helm_chart_prometheus = {
    version     = "41.4.1"
    releaseName = "kube-prometheus-stack"
    namespace   = "monitoring"
  }

  helm_chart_velero = {
    version     = "2.32.1"
    releaseName = "velero"
    namespace   = "velero"
  }

}