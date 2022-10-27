stack {
  name = "External Snapshotter Controller Stack"
  id   = "aws-es-dev"

  after = [
    "/stacks/dev/eks",
  ]
}