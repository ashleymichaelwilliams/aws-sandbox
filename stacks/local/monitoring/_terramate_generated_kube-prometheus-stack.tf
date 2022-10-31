// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /modules/monitoring/prometheus.tm.hcl

resource "helm_release" "kube-prometheus-stack" {
  chart            = "kube-prometheus-stack"
  create_namespace = true
  depends_on = [
    kubernetes_namespace.monitoring,
  ]
  name       = "kube-prometheus-stack"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "41.4.1"
  wait       = true
}
