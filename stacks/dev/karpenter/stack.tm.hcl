stack {
  name = "Karpenter Node Autoscaling for Kubernetes Stack"
  id   = "k8s-karpenter"

  after = [
    "/stacks/dev/eks",
  ]
}