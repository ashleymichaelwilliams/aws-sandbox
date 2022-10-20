stack {
  name = "Kubecost Cost Analyzer Stack"
  id   = "k8s-kubecost"

  after = [
    "/stacks/dev/alb-controller",
  ]
}