# Generate '_terramate_generated_metrics-server.tf' in each stack

generate_hcl "_terramate_generated_metrics-server.tf" {
  content {

    resource "helm_release" "metrics-server" {
      namespace        = global.helm_chart_metrics-server.namespace
      create_namespace = true

      wait = true

      name       = global.helm_chart_metrics-server.releaseName
      repository = "https://kubernetes-sigs.github.io/metrics-server/"
      chart      = "metrics-server"
      version    = global.helm_chart_metrics-server.version

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

    }

  }
}
