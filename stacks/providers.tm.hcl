generate_hcl "_terramate_generated_providers.tf" {
  content {

    provider "aws" {
      region = global.terraform_aws_provider_region
    }

    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = global.terraform_aws_provider_version
        }
      }
    }

    terraform {
      required_version = global.terraform_version
    }
  }
}
