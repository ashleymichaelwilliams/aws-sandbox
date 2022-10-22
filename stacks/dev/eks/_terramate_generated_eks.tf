// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/eks/eks.tm.hcl

data "aws_partition" "current" {
}
data "aws_caller_identity" "current" {
}
locals {
  cluster_version = "1.22"
  name            = "ex-eks"
  partition       = data.aws_partition.current.partition
  region          = "us-west-2"
  tags = merge({
    env   = "dev"
    stack = "aws-eks-dev"
    team  = "devops"
    },
    {
      GithubRepo = "terraform-aws-eks"
      GithubOrg  = "terraform-aws-modules"
  })
}
module "eks" {
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }
  cluster_enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources = [
        "secrets",
      ]
    },
  ]
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_name                    = local.name
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
  cluster_tags = {
    Name = local.name
  }
  cluster_version            = local.cluster_version
  create_cni_ipv6_iam_policy = false
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
    instance_types = [
      "t3.medium",
    ]
    iam_role_attach_cni_policy = true
  }
  eks_managed_node_groups = {

    # Spot Instance Managed Node Group managed by Karpenter
    spot = {
      name            = "spot-eks-mng"
      use_name_prefix = true

      subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

      min_size     = 2
      max_size     = 5
      desired_size = 2

      ami_id                     = data.aws_ami.eks_default.image_id
      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--container-runtime containerd --kubelet-extra-args '--max-pods=20'"

      pre_bootstrap_user_data = <<-EOT
          export CONTAINER_RUNTIME="containerd"
          export USE_MAX_PODS=false
          EOT

      post_bootstrap_user_data = <<-EOT
          echo "you are free little kubelet!"
          EOT

      capacity_type        = "SPOT"
      force_update_version = true
      instance_types = [
        "t3.medium",
      ]
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      # taints = [
      #   {
      #     key   = "capacity_type"
      #     value = "SPOT"

      #     effect = "NO_SCHEDULE"
      #   }
      # ]

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }

      description = "EKS managed node group example launch template"

      ebs_optimized = true
      vpc_security_group_ids = [
        aws_security_group.additional.id,
      ]
      disable_api_termination = false
      enable_monitoring       = true

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            iops                  = 150
            throughput            = 150
            encrypted             = true
            kms_key_id            = aws_kms_key.ebs.arn
            delete_on_termination = true
          }
        }
      }

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      create_iam_role          = true
      iam_role_use_name_prefix = false
      iam_role_name            = "eks-managed-node-group-spot-example"
      iam_role_description     = "EKS managed node group spot instance example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      ]
      create_security_group          = true
      security_group_use_name_prefix = false
      security_group_name            = "eks-managed-node-group-spot-example"
      security_group_description     = "EKS managed node group spot instance example security group"
      security_group_tags = {
        Purpose                                = "Protector of the kubelet"
        "karpenter.sh/discovery/${local.name}" = local.name
      }
      security_group_rules = {
        phoneOut = {
          description = "Hello CloudFlare"
          protocol    = "udp"
          from_port   = 53
          to_port     = 53
          type        = "egress"
          cidr_blocks = [
            "1.1.1.1/32",
          ]
        }
        phoneHome = {
          description                   = "Hello cluster"
          protocol                      = "udp"
          from_port                     = 53
          to_port                       = 53
          type                          = "egress"
          source_cluster_security_group = true # bit of reflection lookup
        }
      }

      tags = {
        ExtraTag                               = "EKS managed node group spot example"
        "karpenter.sh/discovery/${local.name}" = local.name
      }
    }
  }
  enable_irsa               = true
  manage_aws_auth_configmap = true
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = [
        "0.0.0.0/0",
      ]
    }
    ingress_karpenter_webhook_tcp = {
      description                   = "Control plane invoke Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_allow_access_from_control_plane = {
      description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  node_security_group_tags = {
    "karpenter.sh/discovery/${local.name}" = local.name
  }
  source     = "terraform-aws-modules/eks/aws"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  tags = merge({
    env   = "dev"
    stack = "aws-eks-dev"
    team  = "devops"
  }, local.tags)
  version = "18.30.0"
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id
}
resource "aws_iam_role_policy_attachment" "additional" {
  for_each   = module.eks.eks_managed_node_groups
  policy_arn = aws_iam_policy.node_additional.arn
  role       = each.value.iam_role_name
}
module "vpc_cni_irsa" {
  attach_vpc_cni_policy = true
  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:aws-node",
      ]
    }
  }
  role_name_prefix    = "VPC-CNI-IRSA"
  source              = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  tags                = local.tags
  version             = "~> 4.12"
  vpc_cni_enable_ipv4 = true
  vpc_cni_enable_ipv6 = false
}
module "ebs_csi_irsa" {
  attach_ebs_csi_policy = true
  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa",
      ]
    }
  }
  role_name = "EBS-CSI-IRSA"
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  tags      = local.tags
  version   = "~> 4.12"
}
resource "aws_security_group" "additional" {
  description = "Addional security group rules"
  name_prefix = "${local.name}-additional"
  tags        = local.tags
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
    description = "Allow SSH from Private networks"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
}
resource "aws_kms_key" "eks" {
  deletion_window_in_days = 7
  description             = "EKS Secret Encryption Key"
  enable_key_rotation     = true
  tags                    = local.tags
}
resource "aws_kms_key" "ebs" {
  deletion_window_in_days = 7
  description             = "Customer managed key to encrypt EKS managed node group volumes"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.ebs.json
}
data "aws_iam_policy_document" "ebs" {
  statement {
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
    sid = "Enable IAM User Permissions"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
      type = "AWS"
    }
  }
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [
      "*",
    ]
    sid = "Allow service-linked role use of the CMK"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,
        # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
      type = "AWS"
    }
  }
  statement {
    actions = [
      "kms:CreateGrant",
    ]
    resources = [
      "*",
    ]
    sid = "Allow attachment of persistent resources"
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
        # required for the ASG to manage encrypted volumes for nodes
        module.eks.cluster_iam_role_arn,
        # required for the cluster / persistentvolume-controller to create encrypted PVCs
      ]
      type = "AWS"
    }
    condition {
      test = "Bool"
      values = [
        "true",
      ]
      variable = "kms:GrantIsForAWSResource"
    }
  }
}
resource "aws_iam_policy" "node_additional" {
  description = "Example usage of node additional policy"
  name        = "${local.name}-additional"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
  tags = local.tags
}
data "aws_ami" "eks_default" {
  most_recent = true
  owners = [
    "amazon",
  ]
  filter {
    name = "name"
    values = [
      "amazon-eks-node-${local.cluster_version}-v*",
    ]
  }
}
locals {
  cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags)
  cluster_autoscaler_label_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for label_name, label_value in coalesce(group.node_group_labels, {}) : "${name}|label|${label_name}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/label/${label_name}",
        value             = label_value,
      }
    }
  ]...)
  cluster_autoscaler_taint_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for taint in coalesce(group.node_group_taints, [
        ]) : "${name}|taint|${taint.key}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}"
        value             = "${taint.value}:${local.taint_effects[taint.effect]}"
      }
    }
  ]...)
  taint_effects = {
    NO_SCHEDULE        = "NoSchedule"
    NO_EXECUTE         = "NoExecute"
    PREFER_NO_SCHEDULE = "PreferNoSchedule"
  }
}
resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
  autoscaling_group_name = each.value.autoscaling_group
  for_each               = local.cluster_autoscaler_asg_tags
  tag {
    key                 = each.value.key
    propagate_at_launch = false
    value               = each.value.value
  }
}
provider "helm" {
  kubernetes {
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    host                   = module.eks.cluster_endpoint
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_id,
      ]
      command = "aws"
    }
  }
}
provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  host                   = module.eks.cluster_endpoint
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_id,
    ]
    command = "aws"
  }
}
module "karpenter_irsa" {
  attach_cluster_autoscaler_policy   = true
  attach_karpenter_controller_policy = true
  attach_vpc_cni_policy              = true
  karpenter_controller_cluster_id    = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["spot"].iam_role_arn,
  ]
  karpenter_controller_ssm_parameter_arns = [
    "arn:${local.partition}:ssm:*:*:parameter/aws/service/*",
  ]
  karpenter_tag_key = "karpenter.sh/discovery/${local.name}"
  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "karpenter:karpenter",
      ]
    }
  }
  role_name           = "karpenter-controller-${local.name}"
  source              = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version             = "~> 4.21.1"
  vpc_cni_enable_ipv4 = true
}
resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${local.name}"
  role = module.eks.eks_managed_node_groups["spot"].iam_role_name
}
resource "helm_release" "karpenter" {
  chart            = "karpenter"
  create_namespace = true
  name             = "karpenter"
  namespace        = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  version          = "v0.18.0"
  wait             = true
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa.iam_role_arn
  }
  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }
  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }
  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}
