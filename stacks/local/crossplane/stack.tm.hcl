stack {
  name = "Crossplane - Cloud Native Control Plane Framework"
  id   = "k8s-crossplane-local"

  after = [
    "/stacks/local/alb-controller",
  ]
}