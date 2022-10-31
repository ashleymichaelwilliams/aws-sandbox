stack {
  name = "KEDA - Kubernetes-based Event Driven Autoscaling"
  id   = "k8s-keda-local"

  after = [
    "/stacks/local/alb-controller",
  ]
}