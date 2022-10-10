# This file is part of Terramate Configuration.
# Terramate is an orchestrator and code generator for Terraform.
# Please see https://github.com/mineiros-io/terramate for more information.
#
# To generate/update Terraform code within the stacks
# run `terramate generate` from root directory of the repository.

globals {
  terraform_version              = "~> 0.14.8"
  terraform_aws_provider_version = "~> 4.34"
  terraform_aws_provider_region  = "us-west-2"
  local_tfstate_path             = "terraform.tfstate"
}
