stack {
  name = "External Snapshotter Controller Stack"
  id   = "aws-es-local"

  after = [
    "/stacks/local/eks",
  ]
}