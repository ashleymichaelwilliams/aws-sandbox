stack {
  name = "Karpenter Node Autoscaling for Kubernetes Stack"
  id   = "k8s-karpenter-local"

  after = [
    "/stacks/local/eks",
  ]
}