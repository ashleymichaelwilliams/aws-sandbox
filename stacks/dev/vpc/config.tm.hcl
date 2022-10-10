globals {
  name = "${global.environment}"

  vpc_cidr_block = "10.0.0.0/16"

  azs = ["${global.region}a", "${global.region}b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
}
