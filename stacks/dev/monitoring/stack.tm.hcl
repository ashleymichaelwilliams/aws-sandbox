stack {
  name = "dev-oregon-monitoring"

  after = [
    "/stacks/dev/eks",
  ]
}