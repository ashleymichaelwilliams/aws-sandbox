stack {
  name = "dev-oregon-alb-controller"

  after = [
    "/stacks/dev/eks",
  ]
}