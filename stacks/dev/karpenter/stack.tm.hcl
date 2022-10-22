stack {
  name = "Karpenter Node Autoscaling for Kubernetes Stack"
  id   = "k8s-karpenter-dev"

  after = [
    "/stacks/dev/eks",
  ]
}