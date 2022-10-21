stack {
  name = "Prometheus Monitoring Stack"
  id   = "k8s-prometheus-local"

  after = [
    "/stacks/local/eks",
  ]
}