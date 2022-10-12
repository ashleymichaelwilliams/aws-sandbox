stack {
  name = "dev-oregon-eks"

  after = [
    "/stacks/dev/vpc",
  ]
}