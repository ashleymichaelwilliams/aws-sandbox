// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/monitoring/metrics-server.tm.hcl

resource "helm_release" "metrics-server" {
  chart            = "metrics-server"
  create_namespace = true
  depends_on = [
    kubernetes_namespace.monitoring,
  ]
  name       = "metrics-server"
  namespace  = "monitoring"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  version    = "3.8.2"
  wait       = true
}
