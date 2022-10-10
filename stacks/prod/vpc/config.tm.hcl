globals {
  name = "${global.environment}"

  vpc_cidr_block = "10.1.0.0/16"

  azs = ["${global.region}a", "${global.region}b", "${global.region}c"]

  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24", "10.1.13.0/24"]
}
