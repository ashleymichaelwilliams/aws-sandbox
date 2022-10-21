stack {
  name = "AWS Load Balancer Controller Stack"
  id   = "aws-alb-local"

  after = [
    "/stacks/local/eks",
  ]
}