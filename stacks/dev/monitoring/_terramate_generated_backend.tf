// TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
// TERRAMATE: originated from generate_hcl block on /stacks/backend.tm.hcl

terraform {
  backend "remote" {
    organization = "adub-widgets"
    workspaces {
      name = "k8s-prometheus-dev"
    }
  }
}
