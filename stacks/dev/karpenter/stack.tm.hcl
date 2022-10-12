stack {
  name = "dev-oregon-karpenter"

  after = [
    "/stacks/dev/eks",
  ]
}