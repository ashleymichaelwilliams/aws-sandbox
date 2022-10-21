stack {
  name = "Kubecost Cost Analyzer Stack"
  id   = "k8s-kubecost-local"

  after = [
    "/stacks/local/alb-controller",
  ]
}