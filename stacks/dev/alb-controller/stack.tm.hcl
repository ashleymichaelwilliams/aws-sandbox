stack {
  name = "AWS Load Balancer Controller Stack"
  id   = "aws-alb"

  after = [
    "/stacks/dev/eks",
  ]
}