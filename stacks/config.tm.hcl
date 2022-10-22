globals {
  local_tfstate_path = "terraform.tfstate"

  terraform_version = "~> 1.2.9"

  terraform_aws_provider_region   = global.region
  terraform_aws_provider_version  = "~> 4.34"
  terraform_k8s_provider_version  = "2.14.0"
  terraform_helm_provider_version = "2.7.0"

  # Leave this and configure override at the environment level
  isLocal = true # Global default unless specified lower in the stack as an override

  # Terraform Cloud Configuration
  tfe_organization = "adub-widgets"
  tfe_workspace    = "${terramate.stack.id}"
  # Usage: dynamically generate string which is the remote state "workspace" name of the 'current' stack/state.
  # Example Result: aws-eks-dev

}
