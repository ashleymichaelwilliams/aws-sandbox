# Generate '_terramate_generated_kube-prometheus-stack.tf' in each stack

generate_hcl "_terramate_generated_kube-prometheus-stack.tf" {
  content {

    resource "helm_release" "kube-prometheus-stack" {
      namespace        = global.helm_chart_prometheus.namespace
      create_namespace = true

      wait = true

      name       = global.helm_chart_prometheus.releaseName
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      version    = global.helm_chart_prometheus.version

      # values = tolist([
      #   <<-YAML
      #   prometheus:
      #     server:
      #       global:
      #         external_labels:
      #           cluster_id: ${data.terraform_remote_state.eks.outputs.cluster_id}
      #     nodeExporter:
      #       enabled: false
      #   ingress:
      #     enabled: true
      #     annotations:
      #       kubernetes.io/ingress.class: alb
      #       alb.ingress.kubernetes.io/target-type: ip
      #       alb.ingress.kubernetes.io/scheme: internet-facing
      #       alb.ingress.kubernetes.io/backend-protocol: HTTP
      #       alb.ingress.kubernetes.io/healthcheck-path: /ui
      #       alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
      #     paths: ["/*"]
      #     pathType: ImplementationSpecific
      #     hosts:
      #       - cost-analyzer.local
      #   YAML
      # ])

      depends_on = [
        kubernetes_namespace.monitoring
      ]
    }

  }
}
