stack {
  name = "Flagger - Progressive Delivery Operator for Kubernetes"
  id   = "k8s-flagger-local"

  after = [
    "/stacks/local/alb-controller",
  ]
}