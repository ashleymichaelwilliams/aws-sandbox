stack {
  name = "Prometheus Monitoring Stack"
  id   = "k8s-prometheus-dev"

  after = [
    "/stacks/dev/eks",
  ]
}