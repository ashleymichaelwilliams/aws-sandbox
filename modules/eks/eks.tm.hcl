# Generate '_terramate_generated_eks.tf' in each stack

generate_hcl "_terramate_generated_eks.tf" {
  content {

    data "terraform_remote_state" "vpc" {
      backend = "local"

      config = {
        path = "../vpc/${global.local_tfstate_path}"
      }

      defaults = {
        vpc_id          = "vpc-123456789"
        private_subnets = ["subnet-123456789"]
      }
    }


    data "aws_partition" "current" {}
    data "aws_caller_identity" "current" {}


    locals {
      name            = global.eks_cluster_name
      cluster_version = "1.22"
      region          = global.terraform_aws_provider_region
      partition       = data.aws_partition.current.partition

      tags = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
    }

    module "eks" {
      source  = "terraform-aws-modules/eks/aws"
      version = "18.30.0"

      cluster_name    = local.name
      cluster_version = local.cluster_version

      vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
      subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

      cluster_endpoint_private_access = true
      cluster_endpoint_public_access  = true

      enable_irsa = true

      create_cni_ipv6_iam_policy = false

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

      manage_aws_auth_configmap = true

      cluster_encryption_config = [{
        provider_key_arn = aws_kms_key.eks.arn
        resources        = ["secrets"]
      }]

      cluster_tags = {
        Name = local.name
      }

      # Extend cluster security group rules
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

      # Extend node-to-node security group rules
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
          cidr_blocks = ["0.0.0.0/0"]
        }
        ingress_karpenter_webhook_tcp = {
          description                   = "Control plane invoke Karpenter webhook"
          protocol                      = "tcp"
          from_port                     = 8443
          to_port                       = 8443
          type                          = "ingress"
          source_cluster_security_group = true
        }
      }

      eks_managed_node_group_defaults = {
        ami_type       = "AL2_x86_64"
        instance_types = ["t3.medium"]

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
          instance_types       = ["t3.medium"]
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

          ebs_optimized           = true
          vpc_security_group_ids  = [aws_security_group.additional.id]
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
            "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
          ]

          create_security_group          = true
          security_group_use_name_prefix = false
          security_group_name            = "eks-managed-node-group-spot-example"
          security_group_description     = "EKS managed node group spot instance example security group"
          security_group_tags = {
            Purpose                                = "Protector of the kubelet"
            "karpenter.sh/discovery/${local.name}" = "${local.name}"
          }
          security_group_rules = {
            phoneOut = {
              description = "Hello CloudFlare"
              protocol    = "udp"
              from_port   = 53
              to_port     = 53
              type        = "egress"
              cidr_blocks = ["1.1.1.1/32"]
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

      tags = merge(global.tags, local.tags)
    }

    resource "aws_iam_role_policy_attachment" "additional" {
      for_each = module.eks.eks_managed_node_groups

      policy_arn = aws_iam_policy.node_additional.arn
      role       = each.value.iam_role_name
    }

    module "vpc_cni_irsa" {
      source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      version = "~> 4.12"

      role_name_prefix      = "VPC-CNI-IRSA"
      attach_vpc_cni_policy = true
      vpc_cni_enable_ipv6   = false
      vpc_cni_enable_ipv4   = true

      oidc_providers = {
        main = {
          provider_arn               = module.eks.oidc_provider_arn
          namespace_service_accounts = ["kube-system:aws-node"]
        }
      }

      tags = local.tags
    }

    resource "aws_security_group" "additional" {
      name_prefix = "${local.name}-additional"
      vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

      ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = [
          "10.0.0.0/8",
          "172.16.0.0/12",
          "192.168.0.0/16",
        ]
      }

      tags = local.tags
    }


    resource "aws_kms_key" "eks" {
      description             = "EKS Secret Encryption Key"
      deletion_window_in_days = 7
      enable_key_rotation     = true

      tags = local.tags
    }

    resource "aws_kms_key" "ebs" {
      description             = "Customer managed key to encrypt EKS managed node group volumes"
      deletion_window_in_days = 7
      policy                  = data.aws_iam_policy_document.ebs.json
    }

    # This policy is required for the KMS key used for EKS root volumes, so the cluster is allowed to enc/dec/attach encrypted EBS volumes
    data "aws_iam_policy_document" "ebs" {
      # Copy of default KMS policy that lets you manage it
      statement {
        sid       = "Enable IAM User Permissions"
        actions   = ["kms:*"]
        resources = ["*"]

        principals {
          type        = "AWS"
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }

      # Required for EKS
      statement {
        sid = "Allow service-linked role use of the CMK"
        actions = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        resources = ["*"]

        principals {
          type = "AWS"
          identifiers = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
            module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
          ]
        }
      }

      statement {
        sid       = "Allow attachment of persistent resources"
        actions   = ["kms:CreateGrant"]
        resources = ["*"]

        principals {
          type = "AWS"
          identifiers = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", # required for the ASG to manage encrypted volumes for nodes
            module.eks.cluster_iam_role_arn,                                                                                                            # required for the cluster / persistentvolume-controller to create encrypted PVCs
          ]
        }

        condition {
          test     = "Bool"
          variable = "kms:GrantIsForAWSResource"
          values   = ["true"]
        }
      }
    }


    resource "aws_launch_template" "external" {
      name_prefix            = "external-eks-ex-"
      description            = "EKS managed node group external launch template"
      update_default_version = true

      block_device_mappings {
        device_name = "/dev/xvda"

        ebs {
          volume_size           = 50
          volume_type           = "gp2"
          delete_on_termination = true
        }
      }

      monitoring {
        enabled = true
      }

      # Disabling due to https://github.com/hashicorp/terraform-provider-aws/issues/23766
      # network_interfaces {
      #   associate_public_ip_address = false
      #   delete_on_termination       = true
      # }

      # if you want to use a custom AMI
      # image_id      = var.ami_id

      # If you use a custom AMI, you need to supply via user-data, the bootstrap script as EKS DOESNT merge its managed user-data then
      # you can add more than the minimum code you see in the template, e.g. install SSM agent, see https://github.com/aws/containers-roadmap/issues/593#issuecomment-577181345
      # (optionally you can use https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/cloudinit_config to render the script, example: https://github.com/terraform-aws-modules/terraform-aws-eks/pull/997#issuecomment-705286151)
      # user_data = base64encode(data.template_file.launch_template_userdata.rendered)

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

      tags = {
        CustomTag = "Launch template custom tag"
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

      tags = local.tags
    }

    resource "aws_security_group" "remote_access" {
      name_prefix = "${local.name}-remote-access"
      description = "Allow remote SSH access"
      vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

      ingress {
        description = "SSH access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

      tags = local.tags
    }

    resource "aws_iam_policy" "node_additional" {
      name        = "${local.name}-additional"
      description = "Example usage of node additional policy"

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
      owners      = ["amazon"]

      filter {
        name   = "name"
        values = ["amazon-eks-node-${local.cluster_version}-v*"]
      }
    }

    data "aws_ami" "eks_default_arm" {
      most_recent = true
      owners      = ["amazon"]

      filter {
        name   = "name"
        values = ["amazon-eks-arm64-node-${local.cluster_version}-v*"]
      }
    }

    data "aws_ami" "eks_default_bottlerocket" {
      most_recent = true
      owners      = ["amazon"]

      filter {
        name   = "name"
        values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
      }
    }

    ################################################################################
    # Tags for the ASG to support cluster-autoscaler scale up from 0
    ################################################################################

    locals {

      # We need to lookup K8s taint effect from the AWS API value
      taint_effects = {
        NO_SCHEDULE        = "NoSchedule"
        NO_EXECUTE         = "NoExecute"
        PREFER_NO_SCHEDULE = "PreferNoSchedule"
      }

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
          for taint in coalesce(group.node_group_taints, []) : "${name}|taint|${taint.key}" => {
            autoscaling_group = group.node_group_autoscaling_group_names[0],
            key               = "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}"
            value             = "${taint.value}:${local.taint_effects[taint.effect]}"
          }
        }
      ]...)

      cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags)
    }

    resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
      for_each = local.cluster_autoscaler_asg_tags

      autoscaling_group_name = each.value.autoscaling_group

      tag {
        key   = each.value.key
        value = each.value.value

        propagate_at_launch = false
      }
    }

    provider "helm" {
      kubernetes {
        host                   = module.eks.cluster_endpoint
        cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

        exec {
          api_version = "client.authentication.k8s.io/v1beta1"
          command     = "aws"
          # This requires the awscli to be installed locally where Terraform is executed
          args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
        }
      }
    }

    provider "kubernetes" {
      host                   = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
      }
    }

    module "karpenter_irsa" {
      source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
      version = "~> 4.21.1"

      role_name = "karpenter-controller-${local.name}"

      attach_karpenter_controller_policy = true
      attach_cluster_autoscaler_policy   = true

      karpenter_controller_cluster_id = module.eks.cluster_id
      karpenter_controller_ssm_parameter_arns = [
        "arn:${local.partition}:ssm:*:*:parameter/aws/service/*"
      ]
      karpenter_controller_node_iam_role_arns = [
        module.eks.eks_managed_node_groups["spot"].iam_role_arn
      ]
      karpenter_tag_key = "karpenter.sh/discovery/${local.name}"

      attach_vpc_cni_policy = true
      vpc_cni_enable_ipv4   = true

      oidc_providers = {
        main = {
          provider_arn               = module.eks.oidc_provider_arn
          namespace_service_accounts = ["karpenter:karpenter"]
        }
      }
    }

    resource "aws_iam_instance_profile" "karpenter" {
      name = "KarpenterNodeInstanceProfile-${local.name}"
      role = module.eks.eks_managed_node_groups["spot"].iam_role_name
    }

    resource "helm_release" "karpenter" {
      namespace        = "karpenter"
      create_namespace = true

      wait = true

      name       = "karpenter"
      repository = "https://charts.karpenter.sh"
      chart      = "karpenter"
      version    = "v0.8.2"

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

  }
}