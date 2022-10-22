stack {
  name = "AWS Load Balancer Controller Stack"
  id   = "aws-alb-dev"

  after = [
    "/stacks/dev/eks",
  ]
}