stack {
  name = "dev-oregon-alb-kubecost"

  after = [
    "/stacks/dev/alb-controller",
  ]
}