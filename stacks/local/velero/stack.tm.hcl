stack {
  name = "Velero - Backup and Restore Tool for Kubernetes"
  id   = "k8s-velero-local"

  after = [
    "/stacks/local/alb-controller",
  ]
}