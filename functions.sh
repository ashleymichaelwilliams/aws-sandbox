tm-apply() {
  terramate fmt && terramate generate && git add -A && \
    terramate run -- terraform init && \
    terramate run -- terraform fmt --check -recursive && \
    terramate run -- terraform validate && \
    terramate run -- terraform apply --auto-approve
}

eks-creds() {
  aws eks update-kubeconfig --name ex-eks && \
  cat <<-EOT >> ~/.kube/config
      env:
      - name: AWS_ACCESS_KEY_ID
        value: ${AWS_ACCESS_KEY_ID}
      - name: AWS_SECRET_ACCESS_KEY
        value: ${AWS_SECRET_ACCESS_KEY}
EOT
}