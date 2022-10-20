stack {
  name = "Prometheus Monitoring Stack"
  id   = "k8s-prometheus"

  after = [
    "/stacks/dev/eks",
  ]
}