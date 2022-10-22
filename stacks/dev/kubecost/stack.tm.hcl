stack {
  name = "Kubecost Cost Analyzer Stack"
  id   = "k8s-kubecost-dev"

  after = [
    "/stacks/dev/alb-controller",
  ]
}