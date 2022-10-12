// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/eks/eks.tm.hcl

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
  defaults = {
    vpc_id = "vpc-123456789"
    private_subnets = [
      "subnet-123456789",
    ]
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
locals {
  cluster_version = "1.22"
  name            = "ex-${replace(basename(path.cwd), "_", "-")}"
  region          = "us-west-2"
  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-eks"
    GithubOrg  = "terraform-aws-modules"
  }
}
data "aws_caller_identity" "current" {
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
  }
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

    # Default node group - as provided by AWS EKS
    default_node_group = {

      create_launch_template = false
      launch_template_name   = ""

      disk_size = 50

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key = aws_key_pair.this.key_name
        source_security_group_ids = [
          aws_security_group.remote_access.id,
        ]
      }
    }

    ### [COMMENTED OUT] ###
    # Default node group - as provided by AWS EKS using Bottlerocket
    # bottlerocket_default = {
    #   # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
    #   # so we need to disable it to use the default template provided by the AWS EKS managed node group service
    #   create_launch_template = false
    #   launch_template_name   = ""

    #   ami_type = "BOTTLEROCKET_x86_64"
    #   platform = "bottlerocket"
    # }

    ### [COMMENTED OUT] ###
    # Adds to the AWS provided user data
    # bottlerocket_add = {
    #   ami_type = "BOTTLEROCKET_x86_64"
    #   platform = "bottlerocket"

    #   # this will get added to what AWS provides
    #   bootstrap_extra_args = <<-EOT
    #   # extra args added
    #   [settings.kernel]
    #   lockdown = "integrity"
    #   EOT
    # }

    ### [COMMENTED OUT] ###
    # Custom AMI, using module provided bootstrap data
    # bottlerocket_custom = {
    #   # Current bottlerocket AMI
    #   ami_id   = data.aws_ami.eks_default_bottlerocket.image_id
    #   platform = "bottlerocket"

    #   # use module user data template to boostrap
    #   enable_bootstrap_user_data = true
    #   # this will get added to the template
    #   bootstrap_extra_args = <<-EOT
    #   # extra args added
    #   [settings.kernel]
    #   lockdown = "integrity"
    #   [settings.kubernetes.node-labels]
    #   "label1" = "foo"
    #   "label2" = "bar"
    #   [settings.kubernetes.node-taints]
    #   "dedicated" = "experimental:PreferNoSchedule"
    #   "special" = "true:NoSchedule"
    #   EOT
    # }

    ### [COMMENTED OUT] ###
    # Use existing/external launch template
    # external_lt = {
    #   create_launch_template  = false
    #   launch_template_name    = aws_launch_template.external.name
    #   launch_template_version = aws_launch_template.external.default_version
    # }

    ### [COMMENTED OUT] ###
    # Use a custom AMI
    # custom_ami = {
    #   ami_type = "AL2_ARM_64"
    #   # Current default AMI used by managed node groups - pseudo "custom"
    #   ami_id = data.aws_ami.eks_default_arm.image_id

    #   enable_bootstrap_user_data = true

    #   instance_types = ["t4g.medium"]
    # }

    ### [COMMENTED OUT] ###
    # Demo of containerd usage when not specifying a custom AMI ID
    # (merged into user data before EKS MNG provided user data)
    # containerd = {
    #   name = "containerd"

    #   # See issue https://github.com/awslabs/amazon-eks-ami/issues/844
    #   pre_bootstrap_user_data = <<-EOT
    #   #!/bin/bash
    #   set -ex
    #   cat <<-EOF > /etc/profile.d/bootstrap.sh
    #   export CONTAINER_RUNTIME="containerd"
    #   export USE_MAX_PODS=false
    #   export KUBELET_EXTRA_ARGS="--max-pods=110"
    #   EOF
    #   # Source extra environment variables in bootstrap script
    #   sed -i '/^set -o errexit/a\\nsource /etc/profile.d/bootstrap.sh' /etc/eks/bootstrap.sh
    #   EOT
    # }

    # Complete
    complete = {
      name            = "complete-eks-mng"
      use_name_prefix = true

      subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

      min_size     = 3
      max_size     = 5
      desired_size = 3

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
      iam_role_name            = "eks-managed-node-group-complete-example"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group complete example role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      ]
      create_security_group          = true
      security_group_name            = "eks-managed-node-group-complete-example"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group complete example security group"
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
      security_group_tags = {
        Purpose = "Protector of the kubelet"
      }

      tags = {
        ExtraTag = "EKS managed node group complete example"
      }
    }
  }
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
  }
  source     = "terraform-aws-modules/eks/aws"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets
  tags = {
    env   = "dev"
    stack = "dev-oregon-eks"
    team  = "devops"
  }
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
resource "aws_security_group" "additional" {
  name_prefix = "${local.name}-additional"
  tags        = local.tags
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
    from_port = 22
    protocol  = "tcp"
    to_port   = 22
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
resource "aws_launch_template" "external" {
  description = "EKS managed node group external launch template"
  name_prefix = "external-eks-ex-"
  tags = {
    CustomTag = "Launch template custom tag"
  }
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp2"
    }
  }
  monitoring {
    enabled = true
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name      = "external_lt"
      CustomTag = "Instance custom tag"
    }
  }
  tag_specifications {
    resource_type = "volume"
    tags = {
      CustomTag = "Volume custom tag"
    }
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = {
      CustomTag = "EKS example"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "tls_private_key" "this" {
  algorithm = "RSA"
}
resource "aws_key_pair" "this" {
  key_name_prefix = local.name
  public_key      = tls_private_key.this.public_key_openssh
  tags            = local.tags
}
resource "aws_security_group" "remote_access" {
  description = "Allow remote SSH access"
  name_prefix = "${local.name}-remote-access"
  tags        = local.tags
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  ingress {
    cidr_blocks = [
      "10.0.0.0/8",
    ]
    description = "SSH access"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  egress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port = 0
    protocol  = "-1"
    to_port   = 0
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
data "aws_ami" "eks_default_arm" {
  most_recent = true
  owners = [
    "amazon",
  ]
  filter {
    name = "name"
    values = [
      "amazon-eks-arm64-node-${local.cluster_version}-v*",
    ]
  }
}
data "aws_ami" "eks_default_bottlerocket" {
  most_recent = true
  owners = [
    "amazon",
  ]
  filter {
    name = "name"
    values = [
      "bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*",
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