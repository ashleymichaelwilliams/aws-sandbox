globals {
  environment = "local"

  name = "${global.environment}"

  region = "us-west-2"
  azs    = ["${global.region}a", "${global.region}b"]

  vpc_cidr_block  = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]

  eks_cluster_name = "ex-eks"

  kapenter_limits_cpu    = "32"
  kapenter_limits_memory = "64Gi"

  tags = {
    env   = global.environment
    team  = "devops"
    stack = terramate.stack.id
  }

  # Backend Configuration 
  isLocal = true # true==Local Backend or false==Terrform Cloud Backend  

  external_snapshotter_version = "6.1.0"
}