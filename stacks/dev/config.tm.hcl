globals {
  region = global.terraform_aws_provider_region

  environment = "dev"

  eks_cluster_name = "ex-eks"

  tags = {
    env   = global.environment
    team  = "devops"
    stack = terramate.stack.name
  }
}